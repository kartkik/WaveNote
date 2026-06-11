# WaveNote 🎙️

A Swift/SwiftUI iOS audio recorder with real-time waveform visualisations, a recordings list, and a unified player.

---

## Features

| Feature | Details |
|---|---|
| **Record** | Tap the floating mic button to start. Tapping the checkmark stops and saves it. Audio is saved as `.m4a` (AAC, 44,100 Hz). |
| **Live Waveforms** | 60-bar horizontal animated waveform + concentric circular waveform visualizer powered by `AVAudioRecorder` metering + SwiftUI `Canvas`, updated at 30 fps. |
| **Recordings List** | Shows title, duration, and date/time. Supports inline actions (play/pause capsule, rename alert, share link, and delete menu). |
| **Playback** | Unified slide-up sheet featuring a real-time circular pulsating wave, a rolling bar wave, slider scrubber, and play/pause controls. |
| **Persistence** | Recordings metadata is stored as JSON in the app's Documents directory; audio files are preserved across launches. |
| **Microphone Permission** | Requests permission at first use; shows a Settings redirect alert if denied. |

---

## Architecture

```
WaveNote/
├── Models/
│   └── Recording.swift            — Codable data model
├── Services/
│   ├── AudioRecorderService.swift — AVAudioRecorder + 30 fps metering
│   ├── AudioPlayerService.swift   — AVAudioPlayer + 30 fps progress & metering timer
│   └── FileStorageService.swift   — JSON metadata + file management
├── ViewModels/
│   ├── RecorderViewModel.swift    — Recording flow, waveform buffer, list CRUD
│   └── PlayerViewModel.swift      — Playback state bridge
└── Views/
    ├── HomeView.swift             — Main screen & Unified bottom sheet
    ├── WaveformView.swift         — Rolling bar waveform Canvas
    ├── CircularWaveformView.swift — Real-time pulsing glow ring visualizer
    ├── FluidWaveformView.swift    — Organic wave animation (splash/compact sheet)
    ├── RecordingRowView.swift     — List row with inline controls and menu
    └── SplashView.swift           — Premium black-and-white entry screen
```

---

## Requirements

- **Xcode 15+** (project targets iOS 17+)
- Physical iPhone or iOS Simulator with microphone access
- Swift 5.9+

---

## Setup

1. Clone or download the repo.
2. Open **WaveNote.xcodeproj** in Xcode.
3. Select your team in *Signing & Capabilities* (or use Personal Team for device testing).
4. Build & run on a device or simulator (`⌘R`).

> **Note:** Microphone recording only works on a physical device or a simulator with the host Mac's microphone enabled.

---

## Tech Stack

| Concern | Solution |
|---|---|
| Recording | `AVAudioRecorder` with metering enabled |
| Live waveforms | `Timer` at 30 fps → `SwiftUI Canvas` |
| Playback | `AVAudioPlayer` |


---

## Bonus Features Implemented

- ✅ Background Recording Enabled
- ✅ Rename recordings (inline button/menu → alert)
- ✅ Delete recordings (inline menu)
- ✅ Share recordings (native SwiftUI ShareLink)
- ✅ Black & White Minimalist visual aesthetics with waveform highlights