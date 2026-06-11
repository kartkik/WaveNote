//
//  PlayerViewModel.swift
//  WaveNote
//
//  Created by twixx on 09/06/26.
//
import Foundation

@Observable
final class PlayerViewModel {


    var isPlaying = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0
    var currentRecording: Recording?
    var waveformSamples: [Float] = Array(repeating: 0.05, count: 60)



    private let playerService = AudioPlayerService()


    init() {}


    func play(_ recording: Recording) {
        playerService.play(recording)
        syncState()
        startObserving()
    }

    func togglePlayPause() {
        if playerService.isPlaying {
            playerService.pause()
        } else {
            playerService.resume()
        }
        syncState()
    }

    func stop() {
        playerService.stop()
        stopObserving()
        syncState()
    }

    func seek(to time: TimeInterval) {
        playerService.seek(to: time)
        currentTime = time
    }

    func skipForward() {
        let targetTime = min(currentTime + 10, duration)
        seek(to: targetTime)
    }

    func skipBackward() {
        let targetTime = max(currentTime - 10, 0)
        seek(to: targetTime)
    }


    private var syncTimer: Timer?

    private func startObserving() {
        syncTimer?.invalidate()
        syncTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.syncState()
        }
    }

    private func stopObserving() {
        syncTimer?.invalidate()
        syncTimer = nil
    }

    private func syncState() {
        isPlaying = playerService.isPlaying
        currentTime = playerService.currentTime
        duration = playerService.duration
        currentRecording = playerService.currentRecording
        waveformSamples = playerService.waveformSamples

        if !playerService.isPlaying && currentTime == 0 && currentRecording == nil {
            stopObserving()
        }
    }
}
