//
//  RecorderViewModel.swift
//  WaveNote
//
//  Created by twixx on 09/06/26.
//
import Foundation
import AVFoundation

@Observable
final class RecorderViewModel {

    // MARK: - Published state

    var recordings: [Recording] = []
    var isRecording = false
    var saveSuccess = false
    var recordingDuration: TimeInterval = 0
    var waveformSamples: [Float] = Array(repeating: 0, count: 60)
    var showPermissionAlert = false
    var errorMessage: String?

    var meteringLevel: Float {
        recorderService.meteringLevel
    }

    // MARK: - Dependencies

    private let recorderService = AudioRecorderService()
    private let storage = FileStorageService.shared
    private var recordingStartTime: Date?

    // MARK: - Init

    init() {
        recordings = storage.load()
        // Mirror recorder's metering into our waveform buffer
    }

    // MARK: - Recording control

    var isPaused: Bool {
        recorderService.isPaused
    }

    func toggleRecording() {
        if isRecording {
            finishRecording()
        } else {
            requestPermissionAndRecord()
        }
    }

    func togglePauseResume() {
        if isPaused {
            recorderService.resumeRecording()
            if recordingStartTime != nil {
                recordingStartTime = Date() - recordingDuration
            } else {
                recordingStartTime = Date()
            }
            startMeteringObservation()
        } else {
            recorderService.pauseRecording()
            meteringTimer?.invalidate()
        }
    }

    private func requestPermissionAndRecord() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            Task { @MainActor in
                if granted {
                    self?.beginRecording()
                } else {
                    self?.showPermissionAlert = true
                }
            }
        }
    }

    private func beginRecording() {
        let url = storage.newRecordingURL()
        do {
            try recorderService.startRecording(to: url)
            isRecording = true
            recordingStartTime = Date()
            recordingDuration = 0
            startMeteringObservation()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func finishRecording() {
        guard let url = recorderService.stopRecording() else { return }
        isRecording = false

        let duration = Date().timeIntervalSince(recordingStartTime ?? Date())
        recordingStartTime = nil

        // Reset waveform
        waveformSamples = Array(repeating: 0, count: 60)

        // Save immediately
        let count = recordings.count + 1
        let recording = Recording(
            title: "Recording \(count)",
            url: url,
            date: Date(),
            duration: duration
        )
        recordings.insert(recording, at: 0)
        storage.save(recordings)

        saveSuccess = true

        Task {
            // Keep success state visible for 1.5 seconds before dismissing
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run {
                saveSuccess = false
            }
        }
    }

    // MARK: - Metering → waveform buffer

    private var meteringTimer: Timer?

    private func startMeteringObservation() {
        meteringTimer?.invalidate()
        meteringTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self, self.isRecording else {
                self?.meteringTimer?.invalidate()
                return
            }
            let level = self.recorderService.meteringLevel
            self.appendSample(level)
            
            if let startTime = self.recordingStartTime {
                self.recordingDuration = Date().timeIntervalSince(startTime)
            }
        }
    }

    private func appendSample(_ level: Float) {
        waveformSamples.removeFirst()
        waveformSamples.append(level)
    }

    // MARK: - List actions

    func delete(_ recording: Recording) {
        storage.delete(recording)
        recordings.removeAll { $0.id == recording.id }
        storage.save(recordings)
    }

    func rename(_ recording: Recording, to newTitle: String) {
        guard let idx = recordings.firstIndex(of: recording) else { return }
        recordings[idx].title = newTitle
        storage.save(recordings)
    }

    func toggleFavorite(_ recording: Recording) {
        guard let idx = recordings.firstIndex(of: recording) else { return }
        recordings[idx].isFavorited.toggle()
        storage.save(recordings)
    }
}
