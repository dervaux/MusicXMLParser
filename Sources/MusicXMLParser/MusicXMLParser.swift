import Foundation

/// A Swift package for parsing MusicXML files and extracting musical information
public struct MusicXMLParser {
    
    private let barCounter = BarCounter()
    
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
}
