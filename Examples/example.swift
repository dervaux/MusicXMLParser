import Foundation
import MusicXMLParser

// Example usage of MusicXMLParser

func exampleUsage() {
    let parser = MusicXMLParser()
    
    // Example 1: Count bars from an XML string
    let sampleMusicXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <score-partwise>
        <part id="P1">
            <measure number="1">
                <note>
                    <pitch>
                        <step>C</step>
                        <octave>4</octave>
                    </pitch>
                    <duration>4</duration>
                </note>
            </measure>
            <measure number="2">
                <note>
                    <pitch>
                        <step>D</step>
                        <octave>4</octave>
                    </pitch>
                    <duration>4</duration>
                </note>
            </measure>
            <measure number="3">
                <note>
                    <pitch>
                        <step>E</step>
                        <octave>4</octave>
                    </pitch>
                    <duration>4</duration>
                </note>
            </measure>
        </part>
    </score-partwise>
    """
    
    do {
        let barCount = try parser.countBars(in: sampleMusicXML)
        print("Number of bars in the sample XML: \(barCount)")
    } catch {
        print("Error parsing XML string: \(error)")
    }
    
    // Example 2: Count bars from a file (if it exists)
    let fileURL = URL(fileURLWithPath: "sample.xml")
    
    do {
        let barCount = try parser.countBars(in: fileURL)
        print("Number of bars in file: \(barCount)")
    } catch MusicXMLParseError.fileNotFound {
        print("File not found: \(fileURL.path)")
    } catch {
        print("Error parsing file: \(error)")
    }
}

// Run the example
exampleUsage()
