import Foundation

/// A utility class for counting bars (measures) in MusicXML content
struct BarCounter {
    
    /// Counts the number of measures in the given MusicXML string
    /// - Parameter xmlString: The MusicXML content as a string
    /// - Returns: The number of measures found
    /// - Throws: MusicXMLParseError if parsing fails
    func countMeasures(in xmlString: String) throws -> Int {
        guard let xmlData = xmlString.data(using: .utf8) else {
            throw MusicXMLParseError.invalidXMLFormat
        }
        
        let parser = XMLParser(data: xmlData)
        let delegate = MeasureCounterDelegate()
        parser.delegate = delegate
        
        guard parser.parse() else {
            let errorMessage = parser.parserError?.localizedDescription ?? "Unknown parsing error"
            throw MusicXMLParseError.xmlParsingFailed(errorMessage)
        }
        
        if delegate.measureCount == 0 {
            throw MusicXMLParseError.noMeasuresFound
        }
        
        return delegate.measureCount
    }
}

/// XMLParser delegate for counting measures
private class MeasureCounterDelegate: NSObject, XMLParserDelegate {
    var measureCount = 0
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "measure" {
            measureCount += 1
        }
    }
}
