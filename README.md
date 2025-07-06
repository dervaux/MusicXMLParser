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

The functions below accept parameters that can be either a URL (for file-based input) or a String (for direct XML content).

- `countBars` - Count the number of bars
