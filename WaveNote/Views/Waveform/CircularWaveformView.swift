//
//  CircularWaveformView.swift
//  WaveNote
//
//  Created by twixx on 09/06/26.
//
import SwiftUI

struct CircularWaveformView: View {
    var samples: [Float]
    
    var primaryColor: Color = .appBlue
    var secondaryColor: Color = .appBlueLight
    var tertiaryColor: Color = .appBlueMedium
    
    private var activeLevel: CGFloat {
        if let last = samples.last {
            return CGFloat(last)
        }
        return 0.15
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let level = activeLevel
            
            let baseSize: CGFloat = 110
            
            // Oscillating scale factors driven by real-time sound levels + timer
            let scale1 = 1.0 + level * 0.75 + 0.08 * sin(time * 3.0)
            let scale2 = 0.95 + level * 0.95 + 0.11 * cos(time * 2.4)
            let scale3 = 1.05 + level * 0.65 + 0.07 * sin(time * 4.2)
            let scale4 = 0.88 + level * 0.85 + 0.10 * cos(time * 3.3)
            
            ZStack {
                // Layer 1: Glowing Indigo Background
                Circle()
                    .fill(primaryColor)
                    .frame(width: baseSize, height: baseSize)
                    .scaleEffect(scale1)
                    .blur(radius: 24)
                    .opacity(0.35)
                
                // Layer 2: Glowing Purple
                Circle()
                    .fill(tertiaryColor)
                    .frame(width: baseSize * 0.95, height: baseSize * 0.95)
                    .scaleEffect(scale2)
                    .blur(radius: 22)
                    .opacity(0.40)
                
                // Layer 3: Glowing Pink
                Circle()
                    .fill(secondaryColor)
                    .frame(width: baseSize * 0.9, height: baseSize * 0.9)
                    .scaleEffect(scale3)
                    .blur(radius: 20)
                    .opacity(0.45)
                
                // Layer 4: Glowing Cyan Core
                Circle()
                    .fill(primaryColor)
                    .frame(width: baseSize * 0.85, height: baseSize * 0.85)
                    .scaleEffect(scale4)
                    .blur(radius: 16)
                    .opacity(0.50)
                
                // Glassmorphic center mask overlay
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: baseSize * 0.85, height: baseSize * 0.85)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            }
        }
        .frame(width: 200, height: 200)
    }
}

#Preview {
    CircularWaveformView(samples: Array(repeating: 0.15, count: 60))
        .frame(width: 200, height: 200)
        .background(Color.white)
}
