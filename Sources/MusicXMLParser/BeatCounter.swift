import Foundation

/// Internal class responsible for counting played beats in MusicXML content
class BeatCounter {
    
    /// Counts the total played beats in the given MusicXML string, excluding silences
    /// - Parameters:
    ///   - xmlString: The MusicXML content as a string
    ///   - referenceNoteType: The note type to use as a reference for beat counting
    /// - Returns: The total number of played beats as a Double
    /// - Throws: MusicXMLParseError if parsing fails
    func countPlayedBeats(in xmlString: String, referenceNoteType: NoteType) throws -> Double {
        guard let xmlData = xmlString.data(using: .utf8) else {
            throw MusicXMLParseError.invalidXMLFormat
        }
        
        let parser = XMLParser(data: xmlData)
        let delegate = BeatCounterDelegate(referenceNoteType: referenceNoteType)
        parser.delegate = delegate
        
        guard parser.parse() else {
            let errorMessage = parser.parserError?.localizedDescription ?? "Unknown parsing error"
            throw MusicXMLParseError.xmlParsingFailed(errorMessage)
        }
        
        return delegate.totalBeats
    }
}

/// XMLParser delegate for counting played beats
private class BeatCounterDelegate: NSObject, XMLParserDelegate {
    private let referenceNoteType: NoteType
    private var totalPlayedBeats: Double = 0.0
    private var currentElementName: String = ""
    private var currentNoteType: String = ""
    private var isCurrentNoteRest: Bool = false
    
    init(referenceNoteType: NoteType) {
        self.referenceNoteType = referenceNoteType
        super.init()
    }
    
    var totalBeats: Double {
        return totalPlayedBeats
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElementName = elementName
        
        if elementName == "note" {
            // Reset note state for new note
            currentNoteType = ""
            isCurrentNoteRest = false
        } else if elementName == "rest" {
            // Mark current note as a rest
            isCurrentNoteRest = true
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if currentElementName == "type" && !trimmedString.isEmpty {
            currentNoteType = trimmedString
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "note" {
            // Process the completed note
            processNote()
        }
        currentElementName = ""
    }
    
    private func processNote() {
        // Skip rests (silences)
        guard !isCurrentNoteRest else {
            return
        }
        
        // Skip notes without type information
        guard !currentNoteType.isEmpty else {
            return
        }
        
        // Find the note type and calculate beats
        if let noteType = NoteType.allCases.first(where: { $0.rawValue == currentNoteType }) {
            let noteBeats = noteType.beatValue / referenceNoteType.beatValue
            totalPlayedBeats += noteBeats
        }
    }
}
