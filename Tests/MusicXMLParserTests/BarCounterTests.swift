import XCTest
@testable import MusicXMLParser

final class BarCounterTests: XCTestCase {
    
    var barCounter: BarCounter!
    
    override func setUp() {
        super.setUp()
        barCounter = BarCounter()
    }
    
    override func tearDown() {
        barCounter = nil
        super.tearDown()
    }
    
    func testCountMeasuresWithSingleMeasure() throws {
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
            </part>
        </score-partwise>
        """
        
        let measureCount = try barCounter.countMeasures(in: xmlString)
        XCTAssertEqual(measureCount, 1, "Should count 1 measure")
    }
    
    func testCountMeasuresWithMultipleParts() throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <score-partwise>
            <part id="P1">
                <measure number="1">
                    <note><pitch><step>C</step><octave>4</octave></pitch><duration>4</duration></note>
                </measure>
                <measure number="2">
                    <note><pitch><step>D</step><octave>4</octave></pitch><duration>4</duration></note>
                </measure>
            </part>
            <part id="P2">
                <measure number="1">
                    <note><pitch><step>E</step><octave>4</octave></pitch><duration>4</duration></note>
                </measure>
                <measure number="2">
                    <note><pitch><step>F</step><octave>4</octave></pitch><duration>4</duration></note>
                </measure>
            </part>
        </score-partwise>
        """
        
        let measureCount = try barCounter.countMeasures(in: xmlString)
        XCTAssertEqual(measureCount, 4, "Should count all measures across all parts")
    }
    
    func testCountMeasuresWithNoMeasures() {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <score-partwise>
            <part id="P1">
            </part>
        </score-partwise>
        """
        
        XCTAssertThrowsError(try barCounter.countMeasures(in: xmlString)) { error in
            XCTAssertTrue(error is MusicXMLParseError)
            if case MusicXMLParseError.noMeasuresFound = error {
                // Expected error
            } else {
                XCTFail("Expected noMeasuresFound error")
            }
        }
    }
}
