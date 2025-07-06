import XCTest
@testable import MusicXMLParser

final class MusicXMLParserTests: XCTestCase {
    
    var parser: MusicXMLParser!
    
    override func setUp() {
        super.setUp()
        parser = MusicXMLParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    func testCountBarsWithValidXMLString() throws {
        let xmlString = """
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
        
        let barCount = try parser.countBars(in: xmlString)
        XCTAssertEqual(barCount, 3, "Should count 3 measures in the XML")
    }
    
    func testCountBarsWithEmptyXML() {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <score-partwise>
            <part id="P1">
            </part>
        </score-partwise>
        """
        
        XCTAssertThrowsError(try parser.countBars(in: xmlString)) { error in
            XCTAssertTrue(error is MusicXMLParseError)
            if case MusicXMLParseError.noMeasuresFound = error {
                // Expected error
            } else {
                XCTFail("Expected noMeasuresFound error")
            }
        }
    }
    
    func testCountBarsWithInvalidXML() {
        let xmlString = "This is not valid XML"
        
        XCTAssertThrowsError(try parser.countBars(in: xmlString)) { error in
            XCTAssertTrue(error is MusicXMLParseError)
            if case MusicXMLParseError.xmlParsingFailed = error {
                // Expected error
            } else {
                XCTFail("Expected xmlParsingFailed error")
            }
        }
    }
    
    func testCountBarsWithNonExistentFile() {
        let nonExistentURL = URL(fileURLWithPath: "/path/to/nonexistent/file.xml")
        
        XCTAssertThrowsError(try parser.countBars(in: nonExistentURL)) { error in
            XCTAssertTrue(error is MusicXMLParseError)
            if case MusicXMLParseError.fileNotFound = error {
                // Expected error
            } else {
                XCTFail("Expected fileNotFound error")
            }
        }
    }
}
