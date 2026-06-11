//
//  RecordingRowView.swift
//  WaveNote
//
//  Created by twixx on 09/06/26.
//
import SwiftUI

struct RecordingRowView: View {

    let recording: Recording
    let isActive: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    let onRename: (String) -> Void
    let onFavorite: () -> Void

    @State private var showRenameAlert = false
    @State private var newTitle = ""
    @State private var heartScale: CGFloat = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(recording.formattedDate)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.gray.opacity(0.8))
            
            Text(recording.title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: 0) {
                Button(action: {
                    HapticFeedback.light()
                    onTap()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isActive ? "pause.fill" : "play.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text(recording.formattedDuration)
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.appLightGray)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                HStack(spacing: 14) {
                    // ── Heart / Favourite button ──
                    Button(action: {
                        HapticFeedback.medium()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            heartScale = 1.35
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                heartScale = 1.0
                            }
                        }
                        onFavorite()
                    }) {
                        Image(systemName: recording.isFavorited ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundStyle(recording.isFavorited ? Color.pink : Color.black.opacity(0.65))
                            .scaleEffect(heartScale)
                    }
                    .buttonStyle(.plain)

                    ShareLink(item: recording.url) {
                        Image(systemName: "paperplane")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.black.opacity(0.65))
                    }
                    .buttonStyle(.plain)

                    Menu {
                        Button {
                            newTitle = recording.title
                            showRenameAlert = true
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            HapticFeedback.warning()
                            onDelete()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.black.opacity(0.65))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 4)
            
            Divider()
                .background(Color.appDivider)
                .padding(.top, 10)
        }
        .padding(.vertical, 8)
        .background(Color.white)
        .alert("Rename Recording", isPresented: $showRenameAlert) {
            TextField("Title", text: $newTitle)
            Button("Save") {
                let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { onRename(trimmed) }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    RecordingRowView(
        recording: Recording(
            title: "Momentum in FIFA and Startup Strategy",
            url: URL(fileURLWithPath: ""),
            date: Date(),
            duration: 83
        ),
        isActive: false,
        onTap: {},
        onDelete: {},
        onRename: { _ in },
        onFavorite: {}
    )
    .padding()
}

