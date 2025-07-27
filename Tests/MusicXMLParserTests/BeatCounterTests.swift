import XCTest
@testable import MusicXMLParser

final class BeatCounterTests: XCTestCase {
    
    var beatCounter: BeatCounter!
    
    override func setUp() {
        super.setUp()
        beatCounter = BeatCounter()
    }
    
    override func tearDown() {
        beatCounter = nil
        super.tearDown()
    }
    
    func testCountPlayedBeatsWithQuarterNoteReference() throws {
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
        
        let playedBeats = try beatCounter.countPlayedBeats(in: xmlString, referenceNoteType: .quarterNote)
        // whole note = 4 quarter beats, half note = 2 quarter beats, quarter note = 1 quarter beat
        // Total: 4 + 2 + 1 = 7 quarter beats
        XCTAssertEqual(playedBeats, 7.0, "Should count 7 quarter beats")
    }
    
    func testCountPlayedBeatsExcludingRests() throws {
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
                        <duration>1</duration>
                        <type>quarter</type>
                    </note>
                    <note>
                        <rest/>
                        <duration>1</duration>
                        <type>quarter</type>
                    </note>
                    <note>
                        <pitch>
                            <step>D</step>
                            <octave>4</octave>
                        </pitch>
                        <duration>1</duration>
                        <type>quarter</type>
                    </note>
                </measure>
            </part>
        </score-partwise>
        """
        
        let playedBeats = try beatCounter.countPlayedBeats(in: xmlString, referenceNoteType: .quarterNote)
        // Only count the two quarter notes, exclude the rest
        // Total: 1 + 1 = 2 quarter beats
        XCTAssertEqual(playedBeats, 2.0, "Should count 2 quarter beats, excluding rest")
    }
    
    func testCountPlayedBeatsWithHalfNoteReference() throws {
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
                        <duration>1</duration>
                        <type>quarter</type>
                    </note>
                </measure>
            </part>
        </score-partwise>
        """
        
        let playedBeats = try beatCounter.countPlayedBeats(in: xmlString, referenceNoteType: .halfNote)
        // whole note = 2 half beats, half note = 1 half beat, quarter note = 0.5 half beats
        // Total: 2 + 1 + 0.5 = 3.5 half beats
        XCTAssertEqual(playedBeats, 3.5, "Should count 3.5 half beats")
    }
    
    func testCountPlayedBeatsWithEighthNoteReference() throws {
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
                        <duration>1</duration>
                        <type>quarter</type>
                    </note>
                    <note>
                        <pitch>
                            <step>D</step>
                            <octave>4</octave>
                        </pitch>
                        <duration>0.5</duration>
                        <type>eighth</type>
                    </note>
                </measure>
            </part>
        </score-partwise>
        """
        
        let playedBeats = try beatCounter.countPlayedBeats(in: xmlString, referenceNoteType: .eighthNote)
        // quarter note = 2 eighth beats, eighth note = 1 eighth beat
        // Total: 2 + 1 = 3 eighth beats
        XCTAssertEqual(playedBeats, 3.0, "Should count 3 eighth beats")
    }
    
    func testCountPlayedBeatsWithNoNotes() throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <score-partwise>
            <part id="P1">
                <measure number="1">
                    <note>
                        <rest/>
                        <duration>4</duration>
                        <type>whole</type>
                    </note>
                </measure>
            </part>
        </score-partwise>
        """
        
        let playedBeats = try beatCounter.countPlayedBeats(in: xmlString, referenceNoteType: .quarterNote)
        // Only rests, no played notes
        XCTAssertEqual(playedBeats, 0.0, "Should count 0 beats when only rests are present")
    }
    
    func testCountPlayedBeatsWithInvalidXML() {
        let invalidXMLString = "This is not valid XML"
        
        XCTAssertThrowsError(try beatCounter.countPlayedBeats(in: invalidXMLString, referenceNoteType: .quarterNote)) { error in
            XCTAssertTrue(error is MusicXMLParseError)
        }
    }
    
    func testNoteTypeEnumBeatValues() {
        XCTAssertEqual(NoteType.wholeNote.beatValue, 1.0)
        XCTAssertEqual(NoteType.halfNote.beatValue, 0.5)
        XCTAssertEqual(NoteType.quarterNote.beatValue, 0.25)
        XCTAssertEqual(NoteType.eighthNote.beatValue, 0.125)
        XCTAssertEqual(NoteType.sixteenthNote.beatValue, 0.0625)
        XCTAssertEqual(NoteType.thirtySecondNote.beatValue, 0.03125)
        XCTAssertEqual(NoteType.sixtyFourthNote.beatValue, 0.015625)
    }

    // MARK: - Count All Beats Tests

    func testCountAllBeatsIncludingRests() throws {
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
                        <duration>1</duration>
                        <type>quarter</type>
                    </note>
                    <note>
                        <rest/>
                        <duration>1</duration>
                        <type>quarter</type>
                    </note>
                    <note>
                        <pitch>
                            <step>D</step>
                            <octave>4</octave>
                        </pitch>
                        <duration>1</duration>
                        <type>quarter</type>
                    </note>
                </measure>
            </part>
        </score-partwise>
        """

        let allBeats = try beatCounter.countAllBeats(in: xmlString, referenceNoteType: .quarterNote)
        // Count all three notes including the rest
        // Total: 1 + 1 + 1 = 3 quarter beats
        XCTAssertEqual(allBeats, 3.0, "Should count 3 quarter beats, including rest")
    }

    func testCountAllBeatsWithOnlyRests() throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <score-partwise>
            <part id="P1">
                <measure number="1">
                    <note>
                        <rest/>
                        <duration>4</duration>
                        <type>whole</type>
                    </note>
                </measure>
            </part>
        </score-partwise>
        """

        let allBeats = try beatCounter.countAllBeats(in: xmlString, referenceNoteType: .quarterNote)
        // One whole note rest = 4 quarter beats
        XCTAssertEqual(allBeats, 4.0, "Should count 4 quarter beats for whole note rest")
    }

    func testCountAllBeatsVsPlayedBeats() throws {
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
                        <duration>2</duration>
                        <type>half</type>
                    </note>
                    <note>
                        <rest/>
                        <duration>2</duration>
                        <type>half</type>
                    </note>
                </measure>
            </part>
        </score-partwise>
        """

        let playedBeats = try beatCounter.countPlayedBeats(in: xmlString, referenceNoteType: .quarterNote)
        let allBeats = try beatCounter.countAllBeats(in: xmlString, referenceNoteType: .quarterNote)

        // Played beats: only the half note = 2 quarter beats
        XCTAssertEqual(playedBeats, 2.0, "Should count 2 quarter beats for played notes only")

        // All beats: half note + half rest = 4 quarter beats
        XCTAssertEqual(allBeats, 4.0, "Should count 4 quarter beats for all notes including rest")

        // All beats should be greater than or equal to played beats
        XCTAssertGreaterThanOrEqual(allBeats, playedBeats, "All beats should be >= played beats")
    }

    func testCountAllBeatsWithMixedNoteTypes() throws {
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
                    <note>
                        <rest/>
                        <duration>2</duration>
                        <type>half</type>
                    </note>
                    <note>
                        <pitch>
                            <step>D</step>
                            <octave>4</octave>
                        </pitch>
                        <duration>1</duration>
                        <type>quarter</type>
                    </note>
                    <note>
                        <rest/>
                        <duration>0.5</duration>
                        <type>eighth</type>
                    </note>
                </measure>
            </part>
        </score-partwise>
        """

        let allBeats = try beatCounter.countAllBeats(in: xmlString, referenceNoteType: .eighthNote)
        // Whole note = 8 eighth beats
        // Half rest = 4 eighth beats
        // Quarter note = 2 eighth beats
        // Eighth rest = 1 eighth beat
        // Total: 8 + 4 + 2 + 1 = 15 eighth beats
        XCTAssertEqual(allBeats, 15.0, "Should count 15 eighth beats for mixed note types including rests")
    }

    func testCountBeatsWithTriplets() throws {
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
                        <duration>1</duration>
                        <type>eighth</type>
                        <time-modification>
                            <actual-notes>3</actual-notes>
                            <normal-notes>2</normal-notes>
                        </time-modification>
                    </note>
                    <note>
                        <pitch>
                            <step>D</step>
                            <octave>4</octave>
                        </pitch>
                        <duration>1</duration>
                        <type>eighth</type>
                        <time-modification>
                            <actual-notes>3</actual-notes>
                            <normal-notes>2</normal-notes>
                        </time-modification>
                    </note>
                    <note>
                        <pitch>
                            <step>E</step>
                            <octave>4</octave>
                        </pitch>
                        <duration>1</duration>
                        <type>eighth</type>
                        <time-modification>
                            <actual-notes>3</actual-notes>
                            <normal-notes>2</normal-notes>
                        </time-modification>
                    </note>
                    <note>
                        <pitch>
                            <step>F</step>
                            <octave>4</octave>
                        </pitch>
                        <duration>3</duration>
                        <type>quarter</type>
                    </note>
                </measure>
            </part>
        </score-partwise>
        """

        let playedBeats = try beatCounter.countPlayedBeats(in: xmlString, referenceNoteType: .quarterNote)
        let allBeats = try beatCounter.countAllBeats(in: xmlString, referenceNoteType: .quarterNote)

        // 3 triplet eighth notes: each is (1/2) * (2/3) = 1/3 quarter beats
        // Total triplet beats: 3 * (1/3) = 1 quarter beat
        // Plus 1 quarter note = 1 quarter beat
        // Total: 1 + 1 = 2 quarter beats
        XCTAssertEqual(playedBeats, 2.0, accuracy: 0.001, "Should count 2.0 quarter beats with triplets")
        XCTAssertEqual(allBeats, 2.0, accuracy: 0.001, "Should count 2.0 quarter beats with triplets (all beats)")
    }

    func testExpress07File() throws {
        // Test the actual Express 07 file that was causing issues
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <score-partwise>
            <part id="P1">
                <measure number="1">
                    <note>
                        <pitch><step>C</step><octave>4</octave></pitch>
                        <duration>1</duration>
                        <type>eighth</type>
                        <time-modification>
                            <actual-notes>3</actual-notes>
                            <normal-notes>2</normal-notes>
                        </time-modification>
                    </note>
                    <note>
                        <pitch><step>E</step><octave>4</octave></pitch>
                        <duration>1</duration>
                        <type>eighth</type>
                        <time-modification>
                            <actual-notes>3</actual-notes>
                            <normal-notes>2</normal-notes>
                        </time-modification>
                    </note>
                    <note>
                        <pitch><step>G</step><octave>4</octave></pitch>
                        <duration>1</duration>
                        <type>eighth</type>
                        <time-modification>
                            <actual-notes>3</actual-notes>
                            <normal-notes>2</normal-notes>
                        </time-modification>
                    </note>
                    <note>
                        <pitch><step>C</step><octave>5</octave></pitch>
                        <duration>1</duration>
                        <type>eighth</type>
                        <time-modification>
                            <actual-notes>3</actual-notes>
                            <normal-notes>2</normal-notes>
                        </time-modification>
                    </note>
                    <note>
                        <pitch><step>E</step><octave>5</octave></pitch>
                        <duration>1</duration>
                        <type>eighth</type>
                        <time-modification>
                            <actual-notes>3</actual-notes>
                            <normal-notes>2</normal-notes>
                        </time-modification>
                    </note>
                    <note>
                        <pitch><step>G</step><octave>5</octave></pitch>
                        <duration>1</duration>
                        <type>eighth</type>
                        <time-modification>
                            <actual-notes>3</actual-notes>
                            <normal-notes>2</normal-notes>
                        </time-modification>
                    </note>
                    <note>
                        <pitch><step>F</step><octave>5</octave></pitch>
                        <duration>1</duration>
                        <type>eighth</type>
                        <time-modification>
                            <actual-notes>3</actual-notes>
                            <normal-notes>2</normal-notes>
                        </time-modification>
                    </note>
                    <note>
                        <pitch><step>D</step><octave>5</octave></pitch>
                        <duration>1</duration>
                        <type>eighth</type>
                        <time-modification>
                            <actual-notes>3</actual-notes>
                            <normal-notes>2</normal-notes>
                        </time-modification>
                    </note>
                    <note>
                        <pitch><step>B</step><octave>4</octave></pitch>
                        <duration>1</duration>
                        <type>eighth</type>
                        <time-modification>
                            <actual-notes>3</actual-notes>
                            <normal-notes>2</normal-notes>
                        </time-modification>
                    </note>
                    <note>
                        <pitch><step>G</step><octave>4</octave></pitch>
                        <duration>1</duration>
                        <type>eighth</type>
                        <time-modification>
                            <actual-notes>3</actual-notes>
                            <normal-notes>2</normal-notes>
                        </time-modification>
                    </note>
                    <note>
                        <pitch><step>F</step><octave>4</octave></pitch>
                        <duration>1</duration>
                        <type>eighth</type>
                        <time-modification>
                            <actual-notes>3</actual-notes>
                            <normal-notes>2</normal-notes>
                        </time-modification>
                    </note>
                    <note>
                        <pitch><step>D</step><octave>4</octave></pitch>
                        <duration>1</duration>
                        <type>eighth</type>
                        <time-modification>
                            <actual-notes>3</actual-notes>
                            <normal-notes>2</normal-notes>
                        </time-modification>
                    </note>
                    <note>
                        <pitch><step>C</step><octave>4</octave></pitch>
                        <duration>3</duration>
                        <type>quarter</type>
                    </note>
                </measure>
            </part>
        </score-partwise>
        """

        let playedBeats = try beatCounter.countPlayedBeats(in: xmlString, referenceNoteType: .quarterNote)
        let allBeats = try beatCounter.countAllBeats(in: xmlString, referenceNoteType: .quarterNote)

        // 12 triplet eighth notes: each is (1/2) * (2/3) = 1/3 quarter beats
        // Total triplet beats: 12 * (1/3) = 4 quarter beats
        // Plus 1 quarter note = 1 quarter beat
        // Total: 4 + 1 = 5 quarter beats
        XCTAssertEqual(playedBeats, 5.0, accuracy: 0.001, "Should count 5.0 quarter beats for Express 07 file")
        XCTAssertEqual(allBeats, 5.0, accuracy: 0.001, "Should count 5.0 quarter beats for Express 07 file (all beats)")
    }
}
