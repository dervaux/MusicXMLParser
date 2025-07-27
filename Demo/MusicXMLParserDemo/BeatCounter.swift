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

    /// Counts all beats in the given MusicXML string, including both played notes and silences
    /// - Parameters:
    ///   - xmlString: The MusicXML content as a string
    ///   - referenceNoteType: The note type to use as a reference for beat counting
    /// - Returns: The total number of beats as a Double
    /// - Throws: MusicXMLParseError if parsing fails
    func countAllBeats(in xmlString: String, referenceNoteType: NoteType) throws -> Double {
        guard let xmlData = xmlString.data(using: .utf8) else {
            throw MusicXMLParseError.invalidXMLFormat
        }

        let parser = XMLParser(data: xmlData)
        let delegate = AllBeatCounterDelegate(referenceNoteType: referenceNoteType)
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
    private var currentActualNotes: Int = 1
    private var currentNormalNotes: Int = 1
    
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
            currentActualNotes = 1
            currentNormalNotes = 1
        } else if elementName == "rest" {
            // Mark current note as a rest
            isCurrentNoteRest = true
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)

        if currentElementName == "type" && !trimmedString.isEmpty {
            currentNoteType = trimmedString
        } else if currentElementName == "actual-notes" && !trimmedString.isEmpty {
            currentActualNotes = Int(trimmedString) ?? 1
        } else if currentElementName == "normal-notes" && !trimmedString.isEmpty {
            currentNormalNotes = Int(trimmedString) ?? 1
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
            let baseBeatValue = noteType.beatValue / referenceNoteType.beatValue
            // Apply time modification (tuplet) if present
            let timeModification = Double(currentNormalNotes) / Double(currentActualNotes)
            let noteBeats = baseBeatValue * timeModification
            totalPlayedBeats += noteBeats
        }
    }
}

/// XMLParser delegate for counting all beats (including rests)
private class AllBeatCounterDelegate: NSObject, XMLParserDelegate {
    private let referenceNoteType: NoteType
    private var totalAllBeats: Double = 0.0
    private var currentElementName: String = ""
    private var currentNoteType: String = ""
    private var currentActualNotes: Int = 1
    private var currentNormalNotes: Int = 1

    init(referenceNoteType: NoteType) {
        self.referenceNoteType = referenceNoteType
        super.init()
    }

    var totalBeats: Double {
        return totalAllBeats
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElementName = elementName

        if elementName == "note" {
            // Reset note state for new note
            currentNoteType = ""
            currentActualNotes = 1
            currentNormalNotes = 1
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)

        if currentElementName == "type" && !trimmedString.isEmpty {
            currentNoteType = trimmedString
        } else if currentElementName == "actual-notes" && !trimmedString.isEmpty {
            currentActualNotes = Int(trimmedString) ?? 1
        } else if currentElementName == "normal-notes" && !trimmedString.isEmpty {
            currentNormalNotes = Int(trimmedString) ?? 1
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "note" {
            // Process the completed note (including rests)
            processNote()
        }
        currentElementName = ""
    }

    private func processNote() {
        // Skip notes without type information
        guard !currentNoteType.isEmpty else {
            return
        }

        // Find the note type and calculate beats (including rests)
        if let noteType = NoteType.allCases.first(where: { $0.rawValue == currentNoteType }) {
            let baseBeatValue = noteType.beatValue / referenceNoteType.beatValue
            // Apply time modification (tuplet) if present
            let timeModification = Double(currentNormalNotes) / Double(currentActualNotes)
            let noteBeats = baseBeatValue * timeModification
            totalAllBeats += noteBeats
        }
    }
}
