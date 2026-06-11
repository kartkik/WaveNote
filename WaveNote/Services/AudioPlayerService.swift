//
//  AudioPlayerService.swift
//  WaveNote
//

import Foundation
import AVFoundation

@Observable
final class AudioPlayerService: NSObject {


    var isPlaying = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0
    var currentRecording: Recording?

    private(set) var waveformSamples: [Float] = Array(repeating: 0.05, count: 60)


    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?


    func play(_ recording: Recording) {
        stop()

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
            audioPlayer?.delegate = self
            audioPlayer?.isMeteringEnabled = true
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

            currentRecording = recording
            duration = audioPlayer?.duration ?? 0
            currentTime = 0
            isPlaying = true
            startProgressTimer()
        } catch {
            print("AudioPlayerService play error: \(error)")
        }
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopProgressTimer()
    }

    func resume() {
        audioPlayer?.play()
        isPlaying = true
        startProgressTimer()
    }

    func stop() {
        stopProgressTimer()
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        currentRecording = nil
        waveformSamples = Array(repeating: 0.05, count: 60)
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }


    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.currentTime = self.audioPlayer?.currentTime ?? 0
            
            if let player = self.audioPlayer, player.isPlaying {
                player.updateMeters()
                let avg = player.averagePower(forChannel: 0)
                let minDb: Float = -60.0
                let level = max(0, (avg - minDb) / -minDb)
                
                self.waveformSamples.removeFirst()
                self.waveformSamples.append(level)
            }
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}


extension AudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0
        stopProgressTimer()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
