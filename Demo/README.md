# MusicXMLParser Demo

This is a macOS demo application that showcases the functionality of the MusicXMLParser Swift package.

## Features

- **File Browser**: Select MusicXML files (`.musicxml` or `.xml`) from your computer
- **Sample File**: Load a built-in sample MusicXML file for testing
- **Bar Counting**: Analyze MusicXML files to count the number of measures/bars
- **Error Handling**: Clear error messages when files cannot be parsed
- **Modern UI**: Clean SwiftUI interface with progress indicators

## How to Use

1. **Open the Demo App**: Build and run the MusicXMLParserDemo.xcodeproj in Xcode
2. **Select a File**: 
   - Click "Browse Files" to select a MusicXML file from your computer
   - Or click "Load Sample File" to use the included demo file
3. **View Results**: The app will automatically analyze the file and display:
   - Number of bars/measures found
   - Any parsing errors (click on error icon for details)

## Supported File Types

- `.musicxml` - Standard MusicXML files
- `.xml` - Generic XML files containing MusicXML data

## Sample File

The demo includes a sample MusicXML file (`sample.musicxml`) with:
- 5 measures of simple piano music
- Various note types (whole, half, quarter notes)
- A rest in the final measure (excluded from beat counting)
- Proper MusicXML 3.1 formatting
- Perfect for testing both bar and beat counting functionality

## Requirements

- macOS 15.5 or later
- Xcode 16.4 or later
- Swift 5.0 or later

## Package Operations Demonstrated

The demo showcases:
- **Bar Counting**: `countBars(in: URL)` - Counts measures in MusicXML files
- **Beat Counting**: `countPlayedBeats(in: URL, referenceNoteType: NoteType)` - Counts played beats excluding silences with selectable note type reference

## Architecture

The demo uses:
- **SwiftUI** for the user interface
- **NSOpenPanel** for file selection
- **Async/await** for non-blocking file processing
- **Error handling** with user-friendly messages
- **App Sandbox** with file access permissions

## Troubleshooting

If you encounter issues:
1. Ensure the MusicXML file is properly formatted
2. Check that the file has the correct extension (`.musicxml` or `.xml`)
3. Click on error indicators to see detailed error messages
4. Try the sample file first to verify the app is working correctly
