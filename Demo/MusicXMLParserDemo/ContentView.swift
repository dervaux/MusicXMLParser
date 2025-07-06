//
//  ContentView.swift
//  MusicXMLParserDemo
//
//  Created by Félix Dervaux on 06.07.25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedFileURL: URL?
    @State private var selectedFileName: String = "No file selected"
    @State private var barCount: Int?
    @State private var errorMessage: String?
    @State private var isProcessing: Bool = false

    private let parser = MusicXMLParser()

    var body: some View {
        VStack(spacing: 20) {
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
        errorMessage = nil
        isProcessing = true

        Task {
            do {
                let count = try parser.countBars(in: url)

                await MainActor.run {
                    barCount = count
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isProcessing = false
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
