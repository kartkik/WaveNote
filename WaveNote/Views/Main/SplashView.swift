//
//  SplashView.swift
//  WaveNote
//
//  Created by twixx on 09/06/26.
//
import SwiftUI
import Combine

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var textOffset: CGFloat = 20
    @State private var waveOpacity: Double = 0.0
    
    // Wave samples for the bottom splash animation
    @State private var splashSamples: [Float] = Array(repeating: 0.05, count: 60)
    
    // Timer to drive the wave movement
    private let waveTimer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.black.opacity(0.15), radius: 24, x: 0, y: 12)
                    
                    Image(systemName: "waveform")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(.white)
                        .symbolEffect(.variableColor.iterative, options: .repeating)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .padding(.bottom, 24)
                
                VStack(spacing: 8) {
                    Text("WaveNote")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(.black)
                    
                    Text("Voice recording, reimagined")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.gray.opacity(0.8))
                }
                .opacity(textOpacity)
                .offset(y: textOffset)
                
                Spacer()
                
                FluidWaveformView(
                    samples: splashSamples,
                    primaryColor: .appBlue,
                    secondaryColor: .appBlueLight,
                    tertiaryColor: .appBlueMedium
                )
                .frame(height: 120)
                .opacity(waveOpacity)
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .onAppear {
            // Trigger logo animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.65, blendDuration: 0)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // Trigger text animation with small delay
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                textOpacity = 1.0
                textOffset = 0
            }
            
            // Trigger wave fade-in
            withAnimation(.easeIn(duration: 1.0).delay(0.4)) {
                waveOpacity = 1.0
            }
        }
        .onReceive(waveTimer) { _ in
            let time = Date().timeIntervalSinceReferenceDate
            for i in 0..<splashSamples.count {
                let x = CGFloat(i)
                let val = 0.12 
                    + 0.08 * sin(x * 0.12 + CGFloat(time) * 2.5) 
                    + 0.05 * cos(x * 0.28 - CGFloat(time) * 1.8)
                    + 0.03 * sin(x * 0.05 + CGFloat(time) * 0.9)
                splashSamples[i] = Float(val)
            }
        }
    }
}

#Preview {
    SplashView()
}
