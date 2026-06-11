//
//  ContentView.swift
//  WaveNote
//
//  Created by twixx on 09/06/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isSplashActive = true
    
    var body: some View {
        ZStack {
            if isSplashActive {
                SplashView()
                    .transition(.opacity)
            } else {
                HomeView()
                    .transition(.opacity)
            }
        }
        .task {
            // Display splash screen for 2.5 seconds, then transition
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            withAnimation(.easeInOut(duration: 0.5)) {
                isSplashActive = false
            }
        }
    }
}

#Preview {
    ContentView()
}
