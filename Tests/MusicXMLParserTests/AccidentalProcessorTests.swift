import XCTest
@testable import MusicXMLParser

final class AccidentalProcessorTests: XCTestCase {
    
    var parser: MusicXMLParser!
    
    override func setUp() {
        super.setUp()
        parser = MusicXMLParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    func testAddExplicitAccidentalsWithCMajor() throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <score-partwise version="3.1">
          <part id="P1">
            <measure number="1">
              <attributes>
                <key>
                  <fifths>0</fifths>
                </key>
              </attributes>
              <note>
                <pitch>
                  <step>C</step>
                  <octave>4</octave>
                </pitch>
                <duration>4</duration>
                <type>whole</type>
              </note>
            </measure>
          </part>
        </score-partwise>
        """
        
        let result = try parser.addExplicitAccidentals(to: xmlString)
        
        // In C major, C should not have any accidental added
        XCTAssertTrue(result.contains("<step>C</step>"))
        XCTAssertFalse(result.contains("<accidental>"))
    }
    
    func testAddExplicitAccidentalsWithGMajor() throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <score-partwise version="3.1">
          <part id="P1">
            <measure number="1">
              <attributes>
                <key>
                  <fifths>1</fifths>
                </key>
              </attributes>
              <note>
                <pitch>
                  <step>F</step>
                  <octave>4</octave>
                </pitch>
                <duration>4</duration>
                <type>whole</type>
              </note>
            </measure>
          </part>
        </score-partwise>
        """
        
        let result = try parser.addExplicitAccidentals(to: xmlString)

        // In G major (1 sharp), F should have a sharp accidental
        XCTAssertTrue(result.contains("<step>F</step>"))
        XCTAssertTrue(result.contains("<accidental>sharp</accidental>"))
    }
    
    func testAddExplicitAccidentalsWithFMajor() throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <score-partwise version="3.1">
          <part id="P1">
            <measure number="1">
              <attributes>
                <key>
                  <fifths>-1</fifths>
                </key>
              </attributes>
              <note>
                <pitch>
                  <step>B</step>
                  <octave>4</octave>
                </pitch>
                <duration>4</duration>
                <type>whole</type>
              </note>
            </measure>
          </part>
        </score-partwise>
        """
        
        let result = try parser.addExplicitAccidentals(to: xmlString)
        
        // In F major (1 flat), B should have a flat accidental
        XCTAssertTrue(result.contains("<step>B</step>"))
        XCTAssertTrue(result.contains("<accidental>flat</accidental>"))
    }
    
    func testAddExplicitAccidentalsWithExistingAccidental() throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <score-partwise version="3.1">
          <part id="P1">
            <measure number="1">
              <attributes>
                <key>
                  <fifths>1</fifths>
                </key>
              </attributes>
              <note>
                <pitch>
                  <step>F</step>
                  <octave>4</octave>
                </pitch>
                <duration>4</duration>
                <type>whole</type>
                <accidental>natural</accidental>
              </note>
            </measure>
          </part>
        </score-partwise>
        """
        
        let result = try parser.addExplicitAccidentals(to: xmlString)
        
        // Should preserve existing accidental and not add another
        XCTAssertTrue(result.contains("<accidental>natural</accidental>"))
        XCTAssertEqual(result.components(separatedBy: "<accidental>").count - 1, 1) // Only one accidental element
    }
    
    func testAddExplicitAccidentalsWithMultipleNotes() throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <score-partwise version="3.1">
          <part id="P1">
            <measure number="1">
              <attributes>
                <key>
                  <fifths>2</fifths>
                </key>
              </attributes>
              <note>
                <pitch>
                  <step>F</step>
                  <octave>4</octave>
                </pitch>
                <duration>2</duration>
                <type>half</type>
              </note>
              <note>
                <pitch>
                  <step>C</step>
                  <octave>4</octave>
                </pitch>
                <duration>2</duration>
                <type>half</type>
              </note>
            </measure>
          </part>
        </score-partwise>
        """
        
        let result = try parser.addExplicitAccidentals(to: xmlString)
        
        // In D major (2 sharps: F# and C#), both F and C should have sharp accidentals
        XCTAssertTrue(result.contains("<step>F</step>"))
        XCTAssertTrue(result.contains("<step>C</step>"))
        XCTAssertEqual(result.components(separatedBy: "<accidental>sharp</accidental>").count - 1, 2) // Two sharp accidentals
    }
    
    func testAddExplicitAccidentalsWithInvalidXML() {
        let invalidXML = "This is not valid XML"
        
        XCTAssertThrowsError(try parser.addExplicitAccidentals(to: invalidXML)) { error in
            XCTAssertTrue(error is MusicXMLParseError)
        }
    }
}
