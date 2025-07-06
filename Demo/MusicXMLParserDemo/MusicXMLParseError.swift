import Foundation

/// Errors that can occur during MusicXML parsing
public enum MusicXMLParseError: Error, LocalizedError {
    case fileNotFound
    case invalidXMLFormat
    case noMeasuresFound
    case xmlParsingFailed(String)
    case xmlGenerationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "The specified MusicXML file could not be found."
        case .invalidXMLFormat:
            return "The file does not contain valid MusicXML format."
        case .noMeasuresFound:
            return "No measures (bars) were found in the MusicXML file."
        case .xmlParsingFailed(let details):
            return "XML parsing failed: \(details)"
        case .xmlGenerationFailed(let details):
            return "XML generation failed: \(details)"
        }
    }
}
