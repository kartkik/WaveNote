//
//  HomeView.swift
//  WaveNote
//
//  Created by twixx on 09/06/26.
//
import SwiftUI

struct HomeView: View {

    @State private var recorderVM = RecorderViewModel()
    @State private var playerVM   = PlayerViewModel()
    
    @State private var selectedTab = "All"
    @State private var searchQuery = ""
    @State private var isSheetExpanded = false

    private var filteredRecordings: [Recording] {
        var result = recorderVM.recordings
        if !searchQuery.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchQuery) }
        }
        else if selectedTab == "Favorites" {
            return result.filter { $0.isFavorited }
        }
        return result
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    Text("WaveNote")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: {

                          recorderVM.toggleRecording()
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.black)
                        }
                        
            
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)

                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                        
                        TextField("Search", text: $searchQuery)
                            .foregroundStyle(.black)
                            .textInputAutocapitalization(.never)
                        
                        
               
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.appLightGray)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                HStack(spacing: 8) {
                    ForEach(["All", "Favorites"], id: \.self) { tab in
                        Button(action: {
                            HapticFeedback.selection()
                            selectedTab = tab
                        }) {
                            Text(tab)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(selectedTab == tab ? .black : .gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedTab == tab ? Color.appLightGray : Color.clear)
                                .clipShape(Capsule())
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                if filteredRecordings.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "waveform.slash")
                            .font(.system(size: 38))
                            .foregroundStyle(Color.gray.opacity(0.3))
                        Text(selectedTab == "All" ? "No recordings yet" : "No \(selectedTab.lowercased()) items")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.gray.opacity(0.5))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(filteredRecordings) { recording in
                                RecordingRowView(
                                    recording: recording,
                                    isActive: playerVM.currentRecording?.id == recording.id && playerVM.isPlaying,
                                    onTap: {
                                        if playerVM.currentRecording?.id == recording.id {
                                            playerVM.togglePlayPause()
                                        } else {
                                            playerVM.play(recording)
                                        }
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            isSheetExpanded = true
                                        }
                                    },
                                    onDelete: {
                                        if playerVM.currentRecording?.id == recording.id {
                                            playerVM.stop()
                                        }
                                        recorderVM.delete(recording)
                                    },
                                    onRename: { newTitle in
                                        recorderVM.rename(recording, to: newTitle)
                                    },
                                    onFavorite: {
                                        recorderVM.toggleFavorite(recording)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 120)
                    }
                }
            }

            let isSheetVisible = recorderVM.isRecording || recorderVM.isPaused || playerVM.isPlaying || playerVM.currentRecording != nil || recorderVM.saveSuccess
            
            if isSheetVisible {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        if recorderVM.saveSuccess {
                            VStack(spacing: 16) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(Color.appGreen)
                                    .symbolEffect(.bounce, value: recorderVM.saveSuccess)
                                Text("Saved Successfully!")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: isSheetExpanded ? 350 : 120)
                        } else {
                            if isSheetExpanded {
                            VStack(spacing: 20) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        isSheetExpanded = false
                                    }
                                }) {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(Color.black.opacity(0.5))
                                        .padding(6)
                                        .background(Color.appLightGray)
                                        .clipShape(Circle())
                                }
                                
                                VStack(spacing: 4) {
                                    Text(recorderVM.isRecording ? "New Voice Memo" : (playerVM.currentRecording?.title ?? ""))
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(.black)
                                        .lineLimit(1)
                                    
                                    Text(recorderVM.isRecording ? "Recording..." : (playerVM.currentRecording?.formattedDate ?? ""))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.gray)
                                }
                                .padding(.top, 4)
                                
                                
                                HStack(spacing: 24) {
                                    if !recorderVM.isRecording && !recorderVM.isPaused {
                                        Button(action: {
                                            HapticFeedback.light()
                                            playerVM.skipBackward()
                                        }) {
                                            Image(systemName: "gobackward.10")
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundStyle(.black)
                                                .frame(width: 44, height: 44)
                                                .background(Color.appLightGray)
                                                .clipShape(Circle())
                                        }
                                    }

                                    ZStack {
                                        CircularWaveformView(
                                            samples: recorderVM.isRecording || recorderVM.isPaused
                                            ? recorderVM.waveformSamples
                                            : playerVM.waveformSamples,
                                            primaryColor: .appBlue,
                                            secondaryColor: .appBlueLight,
                                            tertiaryColor: .appBlueMedium
                                        )
                                        .frame(width: 180, height: 180)
                                        
                                        Button(action: {
                                            HapticFeedback.medium()
                                            if recorderVM.isRecording || recorderVM.isPaused {
                                                recorderVM.togglePauseResume()
                                            } else {
                                                playerVM.togglePlayPause()
                                            }
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.appLightGray)
                                                    .frame(width: 76, height: 76)
                                                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                                
                                                Image(systemName: (recorderVM.isRecording && !recorderVM.isPaused) || playerVM.isPlaying
                                                      ? "pause.fill"
                                                      : "play.fill")
                                                    .font(.system(size: 26, weight: .bold))
                                                    .foregroundStyle(.black)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }

                                    if !recorderVM.isRecording && !recorderVM.isPaused {
                                        Button(action: {
                                            HapticFeedback.light()
                                            playerVM.skipForward()
                                        }) {
                                            Image(systemName: "goforward.10")
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundStyle(.black)
                                                .frame(width: 44, height: 44)
                                                .background(Color.appLightGray)
                                                .clipShape(Circle())
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                                
                                if !recorderVM.isRecording && !recorderVM.isPaused {
                                    VStack(spacing: 12) {
                                        WaveformView(
                                            samples: playerVM.waveformSamples,
                                            barColor: .appBlue
                                        )
                                        .frame(height: 48)
                                        .padding(.horizontal, 24)
                                        
                                        VStack(spacing: 4) {
                                            Slider(
                                                value: Binding(
                                                    get: { playerVM.duration > 0 ? playerVM.currentTime / playerVM.duration : 0 },
                                                    set: { playerVM.seek(to: $0 * playerVM.duration) }
                                                )
                                            )
                                            .tint(.black)
                                            .padding(.horizontal, 24)
                                            
                                            HStack {
                                                Text(formatDuration(playerVM.currentTime))
                                                Spacer()
                                                Text(formatDuration(playerVM.duration))
                                            }
                                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                            .foregroundStyle(.gray)
                                            .padding(.horizontal, 28)
                                        }
                                    }
                                } else {
                                    VStack(spacing: 12) {
                                        // Live rolling bar waveform (normal wave)
                                        WaveformView(
                                            samples: recorderVM.waveformSamples,
                                            barColor: .appBlue
                                        )
                                        .frame(height: 48)
                                        .padding(.horizontal, 24)
                                        
                                        // Recording Duration Timer
                                        Text(formatDuration(recorderVM.recordingDuration))
                                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                                            .foregroundStyle(.black)
                                    }
                                }
                            }
                        } else {
                            // ── Compact Sheet Layout ──
                            VStack(spacing: 16) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        isSheetExpanded = true
                                    }
                                }) {
                                    Image(systemName: "chevron.up")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(Color.black.opacity(0.5))
                                        .padding(6)
                                        .background(Color.appLightGray)
                                        .clipShape(Circle())
                                }
                                
                                ZStack {
                                    Capsule()
                                        .fill(Color.appDivider.opacity(0.9))
                                        .frame(height: 56)
                                    
                                    FluidWaveformView(
                                        samples: recorderVM.isRecording || recorderVM.isPaused
                                        ? recorderVM.waveformSamples
                                        : playerVM.waveformSamples,
                                        primaryColor: .appBlue,
                                        secondaryColor: .appBlueLight,
                                        tertiaryColor: .appBlueMedium
                                    )
                                    .frame(height: 56)
                                    .clipShape(Capsule())
                                    
                                    HStack {
                                        Button(action: {
                                            HapticFeedback.medium()
                                            if recorderVM.isRecording || recorderVM.isPaused {
                                                recorderVM.togglePauseResume()
                                            } else {
                                                playerVM.togglePlayPause()
                                            }
                                        }) {
                                            Image(systemName: (recorderVM.isRecording && !recorderVM.isPaused) || playerVM.isPlaying
                                                  ? "pause.fill"
                                                  : "play.fill")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundStyle(.black)
                                                .frame(width: 32, height: 32)
                                        }
                                        .padding(.leading, 18)
                                        
                                        Text(formatDuration(recorderVM.isRecording || recorderVM.isPaused ? recorderVM.recordingDuration : playerVM.currentTime))
                                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                                            .foregroundStyle(.black)
                                        
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        // Done Green Button (Always visible at the bottom of the sheet)
                        Button(action: {
                            if recorderVM.isRecording || recorderVM.isPaused {
                                HapticFeedback.success()
                                recorderVM.toggleRecording()
                            } else {
                                HapticFeedback.light()
                                playerVM.stop()
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    isSheetExpanded = false
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Done")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundStyle(Color.appGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.appGreenBg)
                            .clipShape(Capsule())
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: isSheetExpanded ? 32 : 48))
                    .padding(.horizontal, isSheetExpanded ? 0 : 16)
                    .padding(.bottom, isSheetExpanded ? 0 : 16)
                    .background(
                        RoundedRectangle(cornerRadius: isSheetExpanded ? 32 : 48)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: -6)
                    )
                    .frame(maxWidth: isSheetExpanded ? .infinity : 320)
                    .padding(.bottom, isSheetExpanded ? 0 : 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .ignoresSafeArea(edges: isSheetExpanded ? .bottom : [])
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSheetVisible)
            }
            
            if !isSheetVisible {
                VStack {
                    Spacer()
                    
                    Button(action: {
                        HapticFeedback.heavy()
                        recorderVM.toggleRecording()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 72, height: 72)
                                .shadow(color: Color.black.opacity(0.25), radius: 16, x: 0, y: 8)
                            
                            Image(systemName: "mic.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.bottom, 28)
                    .transition(.scale.combined(with: .opacity))
                }
                .ignoresSafeArea(edges: .bottom)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSheetVisible)
            }
        }
        .onChange(of: recorderVM.saveSuccess) { oldValue, newValue in
            if oldValue == true && newValue == false {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isSheetExpanded = false
                }
            }
        }
        .alert("Microphone Access Needed", isPresented: $recorderVM.showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow microphone access in Settings to record audio.")
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    HomeView()
}
