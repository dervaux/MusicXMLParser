import Foundation

/// Note types that can be used as a reference for beat counting
public enum NoteType: String, CaseIterable {
    case wholeNote = "whole"
    case halfNote = "half"
    case quarterNote = "quarter"
    case eighthNote = "eighth"
    case sixteenthNote = "16th"
    case thirtySecondNote = "32nd"
    case sixtyFourthNote = "64th"

    /// Returns the beat value relative to a whole note
    public var beatValue: Double {
        switch self {
        case .wholeNote: return 1.0
        case .halfNote: return 0.5
        case .quarterNote: return 0.25
        case .eighthNote: return 0.125
        case .sixteenthNote: return 0.0625
        case .thirtySecondNote: return 0.03125
        case .sixtyFourthNote: return 0.015625
        }
    }
}

/// A Swift package for parsing MusicXML files and extracting musical information
public struct MusicXMLParser {

    private let barCounter = BarCounter()
    private let beatCounter = BeatCounter()

    /// Initializes a new MusicXMLParser instance
    public init() {}
    
    /// Counts the number of bars (measures) in a MusicXML file
    /// - Parameter fileURL: The URL of the MusicXML file to parse
    /// - Returns: The number of bars found in the file
    /// - Throws: MusicXMLParseError if the file cannot be read or parsed
    public func countBars(in fileURL: URL) throws -> Int {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw MusicXMLParseError.fileNotFound
        }
        
        let xmlString: String
        do {
            xmlString = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            throw MusicXMLParseError.xmlParsingFailed("Failed to read file: \(error.localizedDescription)")
        }
        
        return try countBars(in: xmlString)
    }
    
    /// Counts the number of bars (measures) in a MusicXML string
    /// - Parameter xmlString: The MusicXML content as a string
    /// - Returns: The number of bars found in the XML
    /// - Throws: MusicXMLParseError if the XML cannot be parsed
    public func countBars(in xmlString: String) throws -> Int {
        return try barCounter.countMeasures(in: xmlString)
    }

    /// Counts the total played beats in a MusicXML file, excluding silences
    /// - Parameters:
    ///   - fileURL: The URL of the MusicXML file to parse
    ///   - referenceNoteType: The note type to use as a reference for beat counting
    /// - Returns: The total number of played beats as a Double
    /// - Throws: MusicXMLParseError if the file cannot be read or parsed
    public func countPlayedBeats(in fileURL: URL, referenceNoteType: NoteType) throws -> Double {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw MusicXMLParseError.fileNotFound
        }

        let xmlString: String
        do {
            xmlString = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            throw MusicXMLParseError.xmlParsingFailed("Failed to read file: \(error.localizedDescription)")
        }

        return try countPlayedBeats(in: xmlString, referenceNoteType: referenceNoteType)
    }

    /// Counts the total played beats in a MusicXML string, excluding silences
    /// - Parameters:
    ///   - xmlString: The MusicXML content as a string
    ///   - referenceNoteType: The note type to use as a reference for beat counting
    /// - Returns: The total number of played beats as a Double
    /// - Throws: MusicXMLParseError if the XML cannot be parsed
    public func countPlayedBeats(in xmlString: String, referenceNoteType: NoteType) throws -> Double {
        return try beatCounter.countPlayedBeats(in: xmlString, referenceNoteType: referenceNoteType)
    }
}
