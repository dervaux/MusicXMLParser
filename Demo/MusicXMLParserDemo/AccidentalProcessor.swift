import Foundation

/// Internal class responsible for processing MusicXML content to add explicit accidentals
class AccidentalProcessor {

    /// Processes MusicXML content to add explicit accidentals based on key signatures
    /// - Parameter xmlString: The MusicXML content as a string
    /// - Returns: Modified MusicXML string with explicit accidentals
    /// - Throws: MusicXMLParseError if parsing or generation fails
    func addExplicitAccidentals(to xmlString: String) throws -> String {
        guard let xmlData = xmlString.data(using: .utf8) else {
            throw MusicXMLParseError.invalidXMLFormat
        }

        do {
            let xmlDoc = try XMLDocument(data: xmlData, options: [])
            try processDocument(xmlDoc)
            return xmlDoc.xmlString
        } catch {
            throw MusicXMLParseError.xmlParsingFailed("Failed to process XML: \(error.localizedDescription)")
        }
    }

    private func processDocument(_ document: XMLDocument) throws {
        guard let rootElement = document.rootElement() else {
            throw MusicXMLParseError.invalidXMLFormat
        }

        var currentKeySignature = 0
        try processElement(rootElement, keySignature: &currentKeySignature)
    }

    private func processElement(_ element: XMLElement, keySignature: inout Int) throws {
        // Check if this is a key signature element
        if element.name == "key" {
            if let fifthsElement = element.elements(forName: "fifths").first,
               let fifthsValue = Int(fifthsElement.stringValue ?? "0") {
                keySignature = fifthsValue
            }
        }

        // Check if this is a note element
        if element.name == "note" {
            try processNoteElement(element, keySignature: keySignature)
        }

        // Recursively process child elements
        for child in element.children ?? [] {
            if let childElement = child as? XMLElement {
                try processElement(childElement, keySignature: &keySignature)
            }
        }
    }

    private func processNoteElement(_ noteElement: XMLElement, keySignature: Int) throws {
        // Check if note already has an accidental
        let hasExistingAccidental = !noteElement.elements(forName: "accidental").isEmpty

        // Get the pitch element
        guard let pitchElement = noteElement.elements(forName: "pitch").first,
              let stepElement = pitchElement.elements(forName: "step").first,
              let step = stepElement.stringValue else {
            return // Skip if no pitch information
        }

        // Check if we need to add an accidental
        if !hasExistingAccidental, let accidental = getAccidentalForNote(step: step, keySignature: keySignature) {
            // Create and add the accidental element
            let accidentalElement = XMLElement(name: "accidental")
            accidentalElement.stringValue = accidental
            noteElement.addChild(accidentalElement)
        }
    }

    /// Determines the accidental needed for a note based on the key signature
    /// - Parameters:
    ///   - step: The note step (C, D, E, F, G, A, B)
    ///   - keySignature: Number of sharps (positive) or flats (negative)
    /// - Returns: The accidental string if needed, nil otherwise
    private func getAccidentalForNote(step: String, keySignature: Int) -> String? {
        // Key signature mapping: number of sharps/flats to affected notes
        let sharpOrder = ["F", "C", "G", "D", "A", "E", "B"]
        let flatOrder = ["B", "E", "A", "D", "G", "C", "F"]

        if keySignature > 0 {
            // Sharp key signatures
            if keySignature <= sharpOrder.count && sharpOrder[0..<keySignature].contains(step) {
                return "sharp"
            }
        } else if keySignature < 0 {
            // Flat key signatures
            let numFlats = abs(keySignature)
            if numFlats <= flatOrder.count && flatOrder[0..<numFlats].contains(step) {
                return "flat"
            }
        }

        // No accidental needed for this note in this key signature
        return nil
    }
}
