//
//  AudioRecorderService.swift
//  WaveNote
//
//  Created by twixx on 09/06/26.
//
import Foundation
import AVFoundation

@Observable
final class AudioRecorderService: NSObject {


    var isRecording = false
    var isPaused = false
    var meteringLevel: Float = 0.0


    private var audioRecorder: AVAudioRecorder?
    private var meteringTimer: Timer?
    private var currentURL: URL?

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
            try session.setActive(true)
        } catch {
            AppLogger.error("Failed to configure audio session: \(error.localizedDescription)", category: "AudioRecorder")
            throw error
        }
    }


    func startRecording(to url: URL) throws {
        AppLogger.info("Attempting to start recording to URL: \(url.lastPathComponent)", category: "AudioRecorder")
        do {
            try configureAudioSession()

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()

            currentURL = url
            isRecording = true
            startMetering()
            AppLogger.info("Successfully started recording.", category: "AudioRecorder")
        } catch {
            AppLogger.error("Failed to start recording: \(error.localizedDescription)", category: "AudioRecorder")
            throw error
        }
    }

    @discardableResult
    func stopRecording() -> URL? {
        AppLogger.info("Stopping recording.", category: "AudioRecorder")
        stopMetering()
        audioRecorder?.stop()
        isRecording = false
        isPaused = false
        meteringLevel = 0
        let url = currentURL
        currentURL = nil

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        AppLogger.info("Recording stopped. File saved at: \(url?.lastPathComponent ?? "nil")", category: "AudioRecorder")
        return url
    }

    func pauseRecording() {
        guard isRecording, !isPaused else { return }
        audioRecorder?.pause()
        isPaused = true
        stopMetering()
        AppLogger.info("Recording paused.", category: "AudioRecorder")
    }

    func resumeRecording() {
        guard isRecording, isPaused else { return }
        audioRecorder?.record()
        isPaused = false
        startMetering()
        AppLogger.info("Recording resumed.", category: "AudioRecorder")
    }


    private func startMetering() {
        meteringTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.updateMeter()
        }
        RunLoop.main.add(meteringTimer!, forMode: .common)
    }

    private func stopMetering() {
        meteringTimer?.invalidate()
        meteringTimer = nil
    }

    private func updateMeter() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }
        recorder.updateMeters()
        // averagePower is in dBFS (-160 to 0). Map to 0..1.
        let avg = recorder.averagePower(forChannel: 0)
        let minDb: Float = -60.0
        let level = max(0, (avg - minDb) / -minDb)
        meteringLevel = level
    }
}


extension AudioRecorderService: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        AppLogger.error("Recorder encode error: \(error?.localizedDescription ?? "unknown")", category: "AudioRecorder")
        _ = stopRecording()
    }
}
