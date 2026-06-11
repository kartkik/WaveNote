//
//  HapticFeedback.swift
//  WaveNote
//

import UIKit

enum HapticFeedback {

    // Light tap — row play/pause, chevron expand/collapse, tab switch
    static func light() {
        let g = UIImpactFeedbackGenerator(style: .light)
        g.prepare()
        g.impactOccurred()
    }

    // Medium tap — heart/favourite toggle
    static func medium() {
        let g = UIImpactFeedbackGenerator(style: .medium)
        g.prepare()
        g.impactOccurred()
    }

    // Heavy impact — start recording (big mic button)
    static func heavy() {
        let g = UIImpactFeedbackGenerator(style: .heavy)
        g.prepare()
        g.impactOccurred()
    }

    // Success notification — recording saved (Done button)
    static func success() {
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(.success)
    }

    // Warning notification — delete action
    static func warning() {
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(.warning)
    }

    // Rigid click — selection feedback (rigid style)
    static func selection() {
        let g = UISelectionFeedbackGenerator()
        g.prepare()
        g.selectionChanged()
    }
}
