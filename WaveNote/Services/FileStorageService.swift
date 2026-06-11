//
//  FileStorageService.swift
//  WaveNote
//

import Foundation

final class FileStorageService {

    static let shared = FileStorageService()
    private let metadataFileName = "recordings.json"

    private var recordingsDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("Recordings", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private var metadataURL: URL {
        recordingsDirectory.appendingPathComponent(metadataFileName)
    }


    func newRecordingURL() -> URL {
        let name = "recording_\(Int(Date().timeIntervalSince1970)).m4a"
        return recordingsDirectory.appendingPathComponent(name)
    }


    func save(_ recordings: [Recording]) {
        do {
            let data = try JSONEncoder().encode(recordings)
            try data.write(to: metadataURL, options: .atomic)
            AppLogger.info("Saved  successfully. Total recordings: \(recordings.count)", category: "FileStorage")
        } catch {
            AppLogger.error("FileStorageService save error: \(error.localizedDescription)", category: "FileStorage")
        }
    }

    func load() -> [Recording] {
        guard FileManager.default.fileExists(atPath: metadataURL.path) else {
            AppLogger.info("File does not exist. Returning empty list.", category: "FileStorage")
            return []
        }
        do {
            let data = try Data(contentsOf: metadataURL)
            let recordings = try JSONDecoder().decode([Recording].self, from: data)
            let existing = recordings.filter { FileManager.default.fileExists(atPath: $0.url.path) }
            AppLogger.info("Loaded \(existing.count) recordings successfully (\(recordings.count - existing.count) missing audio files filtered out).", category: "FileStorage")
            return existing
        } catch {
            AppLogger.error("FileStorageService load error: \(error.localizedDescription)", category: "FileStorage")
            return []
        }
    }


    func delete(_ recording: Recording) {
        AppLogger.info("Attempting to delete audio file: \(recording.url.lastPathComponent)", category: "FileStorage")
        do {
            try FileManager.default.removeItem(at: recording.url)
            AppLogger.info("Successfully deleted audio file.", category: "FileStorage")
        } catch {
            AppLogger.error("Failed to delete audio file: \(error.localizedDescription)", category: "FileStorage")
        }
    }
}
