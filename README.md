# MusicXMLParser

A Swift package for parsing MusicXML files and extracting musical information.

## Installation

Add this package to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/dervaux/MusicXMLParser.git", from: "1.0.0")
]
```

## Usage

```swift
import MusicXMLParser

let parser = MusicXMLParser()

// Count bars
let barCount = try parser.countBars(in: fileURL or xmlString)
```

## Available Functions

The functions below accept parameters that can be either a URL (for file-based input) or a String (for direct XML content).

### Bar Counting
- `countBars(in:)` - Count the number of bars

### Beat Counting
- `countPlayedBeats(in fileURL: URL, referenceNoteType: NoteType)` - Count played beats (not silences). The beat counting function returns the total number of played beats using the specified note type as a reference. For example, if you use `.quarterNote` as the reference, a whole note will count as 4 beats, a half note as 2 beats, etc. Rests (silences) are excluded from the count

## Note Types

The `NoteType` enum supports the following note types (for example, for beat counting):

- `.wholeNote` - Whole note
- `.halfNote` - Half note
- `.quarterNote` - Quarter note
- `.eighthNote` - Eighth note
- `.sixteenthNote` - Sixteenth note
- `.thirtySecondNote` - Thirty-second note
- `.sixtyFourthNote` - Sixty-fourth note

