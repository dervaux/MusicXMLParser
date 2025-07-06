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

// Count bars from a file URL
let barCount = try parser.countBars(in: fileURL)

// Count bars from an XML string
let barCount = try parser.countBars(in: xmlString)
```

## Available Functions

- `countBars(in fileURL: URL) throws -> Int` - Count the number of bars in a MusicXML file
- `countBars(in xmlString: String) throws -> Int` - Count the number of bars in a MusicXML string
