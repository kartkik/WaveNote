//
//  AppLogger.swift
//  WaveNote
//
//  Created by twixx on 09/06/26.
//

import Foundation

enum AppLogger {
    static var isEnabled = true

    static func info(_ message: String, category: String) {
        guard isEnabled else { return }
        print("[Info] [\(category)] \(message)")
    }

    static func error(_ message: String, category: String) {
        guard isEnabled else { return }
        print("[Error] [\(category)] \(message)")
    }
}
