//
//  WaveformView.swift
//  WaveNote
//
//  Created by twixx on 09/06/26.
//
import SwiftUI


struct WaveformView: View {

    let samples: [Float]
    var barColor: Color = .white
    var minBarHeight: CGFloat = 3

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let count  = samples.count
                guard count > 0 else { return }

                let spacing: CGFloat = 2
                let totalSpacing = spacing * CGFloat(count - 1)
                let barWidth  = max(2, (size.width - totalSpacing) / CGFloat(count))
                let midY      = size.height / 2

                for (i, sample) in samples.enumerated() {
                    let x = CGFloat(i) * (barWidth + spacing)
                    let halfH = max(minBarHeight / 2, CGFloat(sample) * midY * 0.95)

                    let rect = CGRect(x: x, y: midY - halfH, width: barWidth, height: halfH * 2)
                    let path = Path(roundedRect: rect,
                                    cornerRadius: barWidth / 2)

                    let progress = Double(i) / Double(count)
                    let opacity  = 0.25 + progress * 0.75
                    context.fill(path, with: .color(barColor.opacity(opacity)))
                }
            }
            .animation(.linear(duration: 1.0 / 30.0), value: samples.last)
        }
    }
}


