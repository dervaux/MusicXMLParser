//
//  ContentView.swift
//  MusicXMLParserDemo
//
//  Created by Félix Dervaux on 06.07.25.
//

import SwiftUI
import UniformTypeIdentifiers
import SheetMusicView

struct ContentView: View {
    @State private var selectedFileURL: URL?
    @State private var selectedFileName: String = "No file selected"
    @State private var barCount: Int?
    @State private var playedBeats: Double?
    @State private var selectedNoteType: NoteType = .quarterNote
    @State private var errorMessage: String?
    @State private var isProcessing: Bool = false

    // SheetMusicView state
    @State private var musicXMLContent: String = ""
    @State private var transposeSteps: Int = 0
    @State private var sheetMusicError: String?

    private let parser = MusicXMLParser()

    var body: some View {
        ScrollView {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "music.note.list")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)

                Text("MusicXML Parser Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Select a MusicXML file to analyze")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)

            Divider()

            // File Selection Section
            VStack(spacing: 16) {
                Text("File Selection")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Selected File:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(selectedFileName)
                            .font(.body)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    Spacer()

                    VStack(spacing: 8) {
                        Button("Browse Files") {
                            selectFile()
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Load Sample File") {
                            loadSampleFile()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }

            // Sheet Music Display Section
            if selectedFileURL != nil {
                VStack(spacing: 16) {
                    HStack {
                        Text("Sheet Music Preview")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Transpose controls
                        HStack(spacing: 8) {
                            Text("Transpose:")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Button("-") {
                                if transposeSteps > -12 {
                                    transposeSteps -= 1
                                }
                            }
                            .buttonStyle(.bordered)
                            .disabled(transposeSteps <= -12)

                            Text("\(transposeSteps)")
                                .font(.caption)
                                .frame(width: 20)

                            Button("+") {
                                if transposeSteps < 12 {
                                    transposeSteps += 1
                                }
                            }
                            .buttonStyle(.bordered)
                            .disabled(transposeSteps >= 12)

                            Button("Reset") {
                                transposeSteps = 0
                            }
                            .buttonStyle(.bordered)
                            .disabled(transposeSteps == 0)
                        }
                    }

                    // SheetMusicView
                    if musicXMLContent.isEmpty {
                        VStack(spacing: 12) {
                            ProgressView("Loading sheet music...")
                            Text("Rendering musical notation...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    } else if let error = sheetMusicError {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundColor(.orange)
                            Text("Sheet Music Error")
                                .font(.headline)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    } else {
                        SheetMusicView(
                            xml: $musicXMLContent,
                            transposeSteps: $transposeSteps,
                            onError: { error in
                                sheetMusicError = error.localizedDescription
                            },
                            onReady: {
                                sheetMusicError = nil
                            }
                        )
                        .showTitle()
                        .showComposer()
                        .frame(height: 300)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                }
            }

            // Results Section
            if selectedFileURL != nil {
                VStack(spacing: 16) {
                    Text("Analysis Results")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 12) {
                        // Bar Count Operation
                        OperationResultView(
                            title: "Bar Count",
                            description: "Number of measures in the MusicXML file",
                            icon: "music.note",
                            result: barCount.map { "\($0) bars" },
                            isProcessing: isProcessing,
                            error: errorMessage
                        )

                        Divider()

                        // Beat Count Operation
                        VStack(spacing: 8) {
                            HStack {
                                Text("Beat Count Reference:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Spacer()

                                Picker("Note Type", selection: $selectedNoteType) {
                                    ForEach(NoteType.allCases, id: \.self) { noteType in
                                        Text(noteType.rawValue.capitalized)
                                            .tag(noteType)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 250)
                            }

                            OperationResultView(
                                title: "Played Beats",
                                description: "Total played beats (excluding silences) using \(selectedNoteType.rawValue) note reference",
                                icon: "metronome",
                                result: playedBeats.map { String(format: "%.1f beats", $0) },
                                isProcessing: isProcessing,
                                error: errorMessage
                            )
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
            }

            Spacer()

            // Footer
            Text("Powered by MusicXMLParser Swift Package")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 40)
        .frame(minWidth: 600, minHeight: 500)
        .onChange(of: selectedFileURL) { _, newURL in
            if let url = newURL {
                analyzeFile(url)
            }
        }
        .onChange(of: selectedNoteType) { _, _ in
            if let url = selectedFileURL {
                analyzeFile(url)
            }
        }
    }

    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.xml, UTType(filenameExtension: "musicxml") ?? .xml]
        panel.title = "Select a MusicXML file"
        panel.message = "Choose a MusicXML file to analyze"

        if panel.runModal() == .OK {
            selectedFileURL = panel.url
            selectedFileName = panel.url?.lastPathComponent ?? "Unknown file"
        }
    }

    private func loadSampleFile() {
        // Get the bundle path for the sample file
        if let bundlePath = Bundle.main.path(forResource: "sample", ofType: "musicxml") {
            selectedFileURL = URL(fileURLWithPath: bundlePath)
            selectedFileName = "sample.musicxml (Demo File)"
        } else {
            // Fallback to the file in the Demo directory
            let currentDirectory = FileManager.default.currentDirectoryPath
            let samplePath = URL(fileURLWithPath: currentDirectory).appendingPathComponent("sample.musicxml")

            if FileManager.default.fileExists(atPath: samplePath.path) {
                selectedFileURL = samplePath
                selectedFileName = "sample.musicxml (Demo File)"
            } else {
                errorMessage = "Sample file not found. Please use 'Browse Files' to select a MusicXML file."
            }
        }
    }

    private func analyzeFile(_ url: URL) {
        // Reset previous results
        barCount = nil
        playedBeats = nil
        errorMessage = nil
        isProcessing = true

        // Reset sheet music state
        musicXMLContent = ""
        sheetMusicError = nil
        transposeSteps = 0

        Task {
            do {
                // Load MusicXML content for SheetMusicView
                let xmlContent = try String(contentsOf: url, encoding: .utf8)

                // Parse with MusicXMLParser
                let count = try parser.countBars(in: url)
                let beats = try parser.countPlayedBeats(in: url, referenceNoteType: selectedNoteType)

                await MainActor.run {
                    // Update parser results
                    barCount = count
                    playedBeats = beats
                    isProcessing = false

                    // Update sheet music content
                    musicXMLContent = xmlContent
                }
            } catch {

                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isProcessing = false

                    // Handle sheet music error
                    sheetMusicError = "Failed to load MusicXML: \(error.localizedDescription)"
                }
            }
        }
    }

    private func showErrorAlert(_ error: String) {
        let alert = NSAlert()
        alert.messageText = "MusicXML Parsing Error"
        alert.informativeText = error
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

struct OperationResultView: View {
    let title: String
    let description: String
    let icon: String
    let result: String?
    let isProcessing: Bool
    let error: String?

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Group {
                if isProcessing {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Processing...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if let error = error {
                    Button(action: {
                        showErrorAlert(error)
                    }) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                            Text("Error")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .buttonStyle(.plain)
                } else if let result = result {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(result)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                } else {
                    Text("Ready")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(minWidth: 100, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }

    private func showErrorAlert(_ error: String) {
        let alert = NSAlert()
        alert.messageText = "MusicXML Parsing Error"
        alert.informativeText = error
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

#Preview {
    ContentView()
}
