//
//  Recording.swift
//  WaveNote
//
//  Created by twixx on 09/06/26.
//

import Foundation

struct Recording: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    let url: URL
    let date: Date
    let duration: TimeInterval
    var isFavorited: Bool

    init(id: UUID = UUID(), title: String, url: URL, date: Date, duration: TimeInterval, isFavorited: Bool = false) {
        self.id = id
        self.title = title
        self.url = url
        self.date = date
        self.duration = duration
        self.isFavorited = isFavorited
    }


    var formattedDuration: String {
        let mins = Int(duration) / 60
        let secs = Int(duration) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d · h:mm a"
        return formatter.string(from: date)
    }
}
