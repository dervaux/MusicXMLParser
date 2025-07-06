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

    func testCountPlayedBeatsWithValidXMLString() throws {
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
                        <type>whole</type>
                    </note>
                </measure>
                <measure number="2">
                    <note>
                        <pitch>
                            <step>D</step>
                            <octave>4</octave>
                        </pitch>
                        <duration>2</duration>
                        <type>half</type>
                    </note>
                    <note>
                        <rest/>
                        <duration>2</duration>
                        <type>half</type>
                    </note>
                </measure>
                <measure number="3">
                    <note>
                        <pitch>
                            <step>E</step>
                            <octave>4</octave>
                        </pitch>
                        <duration>1</duration>
                        <type>quarter</type>
                    </note>
                </measure>
            </part>
        </score-partwise>
        """

        let playedBeats = try parser.countPlayedBeats(in: xmlString, referenceNoteType: .quarterNote)
        // whole note = 4 quarter beats, half note = 2 quarter beats, quarter note = 1 quarter beat
        // Rest is excluded, so total: 4 + 2 + 1 = 7 quarter beats
        XCTAssertEqual(playedBeats, 7.0, "Should count 7 quarter beats, excluding rests")
    }

    func testCountPlayedBeatsWithDifferentReferenceNoteTypes() throws {
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
                        <type>whole</type>
                    </note>
                </measure>
            </part>
        </score-partwise>
        """

        // Test with different reference note types
        let wholeBeats = try parser.countPlayedBeats(in: xmlString, referenceNoteType: .wholeNote)
        XCTAssertEqual(wholeBeats, 1.0, "Should count 1 whole beat")

        let halfBeats = try parser.countPlayedBeats(in: xmlString, referenceNoteType: .halfNote)
        XCTAssertEqual(halfBeats, 2.0, "Should count 2 half beats")

        let quarterBeats = try parser.countPlayedBeats(in: xmlString, referenceNoteType: .quarterNote)
        XCTAssertEqual(quarterBeats, 4.0, "Should count 4 quarter beats")

        let eighthBeats = try parser.countPlayedBeats(in: xmlString, referenceNoteType: .eighthNote)
        XCTAssertEqual(eighthBeats, 8.0, "Should count 8 eighth beats")
    }

    func testCountPlayedBeatsWithInvalidXMLString() {
        let invalidXMLString = "This is not valid XML"

        XCTAssertThrowsError(try parser.countPlayedBeats(in: invalidXMLString, referenceNoteType: .quarterNote)) { error in
            XCTAssertTrue(error is MusicXMLParseError)
        }
    }

    func testCountPlayedBeatsWithSampleMusicXMLContent() throws {
        // This is based on the actual sample.musicxml content
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <score-partwise version="3.1">
          <part id="P1">
            <measure number="1">
              <note>
                <pitch>
                  <step>C</step>
                  <octave>4</octave>
                </pitch>
                <duration>4</duration>
                <type>whole</type>
              </note>
            </measure>
            <measure number="2">
              <note>
                <pitch>
                  <step>D</step>
                  <octave>4</octave>
                </pitch>
                <duration>2</duration>
                <type>half</type>
              </note>
              <note>
                <pitch>
                  <step>E</step>
                  <octave>4</octave>
                </pitch>
                <duration>2</duration>
                <type>half</type>
              </note>
            </measure>
            <measure number="3">
              <note>
                <pitch>
                  <step>F</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
              <note>
                <pitch>
                  <step>G</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
              <note>
                <pitch>
                  <step>A</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
              <note>
                <pitch>
                  <step>B</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
            </measure>
            <measure number="4">
              <note>
                <pitch>
                  <step>C</step>
                  <octave>5</octave>
                </pitch>
                <duration>4</duration>
                <type>whole</type>
              </note>
            </measure>
            <measure number="5">
              <note>
                <rest/>
                <duration>4</duration>
                <type>whole</type>
              </note>
            </measure>
          </part>
        </score-partwise>
        """

        // Test with quarter note reference
        let quarterBeats = try parser.countPlayedBeats(in: xmlString, referenceNoteType: .quarterNote)
        // 1 whole (4 quarters) + 2 halves (4 quarters) + 4 quarters (4 quarters) + 1 whole (4 quarters) = 16 quarter beats
        // Rest is excluded
        XCTAssertEqual(quarterBeats, 16.0, "Should count 16 quarter beats from sample content")

        // Test with whole note reference
        let wholeBeats = try parser.countPlayedBeats(in: xmlString, referenceNoteType: .wholeNote)
        // 1 whole + 2 halves (1 whole) + 4 quarters (1 whole) + 1 whole = 4 whole beats
        // Rest is excluded
        XCTAssertEqual(wholeBeats, 4.0, "Should count 4 whole beats from sample content")

        // Test with half note reference
        let halfBeats = try parser.countPlayedBeats(in: xmlString, referenceNoteType: .halfNote)
        // 1 whole (2 halves) + 2 halves (2 halves) + 4 quarters (2 halves) + 1 whole (2 halves) = 8 half beats
        // Rest is excluded
        XCTAssertEqual(halfBeats, 8.0, "Should count 8 half beats from sample content")
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
