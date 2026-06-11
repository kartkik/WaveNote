//
//  FluidWaveformView.swift
//  WaveNote
//
//  Created by twixx on 09/06/26.
//
import SwiftUI

struct FluidWaveformView: View {
    // Rolling audio samples (values from 0.0 to 1.0)
    var samples: [Float]
    
    var primaryColor: Color = .appBlue
    var secondaryColor: Color = .appBlueLight
    var tertiaryColor: Color = .appBlueMedium
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                let width = size.width
                let height = size.height
                
                let wave1 = generateSmoothPath(
                    for: samples,
                    in: size,
                    timePhase: CGFloat(time) * 1.5,
                    sampleOffset: 6,
                    scale: 0.65
                )
                context.fill(wave1, with: .color(primaryColor.opacity(0.25)))
                
                // Draw Wave 2 (Middle: opposite phase offsets)
                let wave2 = generateSmoothPath(
                    for: samples,
                    in: size,
                    timePhase: CGFloat(time) * -2.2,
                    sampleOffset: 3,
                    scale: 0.8
                )
                context.fill(wave2, with: .color(tertiaryColor.opacity(0.4)))
                
                // Draw Wave 3 (Foreground: actual samples)
                let wave3 = generateSmoothPath(
                    for: samples,
                    in: size,
                    timePhase: CGFloat(time) * 3.0,
                    sampleOffset: 0,
                    scale: 1.0
                )
                context.fill(wave3, with: .color(secondaryColor.opacity(0.85)))
            }
        }
    }
    
    private func generateSmoothPath(
        for samples: [Float],
        in size: CGSize,
        timePhase: CGFloat,
        sampleOffset: Int,
        scale: CGFloat
    ) -> Path {
        var path = Path()
        let count = samples.count
        guard count > 1 else { return path }
        
        let stepX = size.width / CGFloat(count - 1)
        
        // Start at bottom left
        path.move(to: CGPoint(x: 0, y: size.height))
        
        var points: [CGPoint] = []
        for i in 0..<count {
            let x = CGFloat(i) * stepX
            
            // Access the sample with an index offset to create wave layers / parallax
            let sampleIndex = max(0, min(count - 1, i + sampleOffset))
            let rawSample = CGFloat(samples[sampleIndex])
            
            // Add a small breathing animation so the wave has a tiny bit of movement even when silent
            let breathing = 0.03 * sin(CGFloat(i) * 0.15 + timePhase)
            let amplitude = max(0.02, rawSample * scale + breathing)
            
            // y goes up from the bottom (meaning y gets smaller)
            let y = size.height - (amplitude * size.height * 0.85)
            points.append(CGPoint(x: x, y: y))
        }
        
        // Construct the smooth quad curve path
        path.addLine(to: points[0])
        for i in 0..<(points.count - 1) {
            let p1 = points[i]
            let p2 = points[i + 1]
            let midPoint = CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
            path.addQuadCurve(to: midPoint, control: p1)
        }
        path.addLine(to: points.last!)
        
        // Close path back to bottom right and then bottom left
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    FluidWaveformView(samples: Array(repeating: 0.1, count: 60))
        .frame(height: 100)
        .background(Color.gray.opacity(0.2))
}
