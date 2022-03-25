//
//  Countdown.swift
//  Strike
//
//  Created by Ata Namvari on 2021-04-19.
//

import Foundation
import SwiftUI
import Combine

struct Countdown: View {
    @Environment(\.font) var font

    var date: Date
    var prefix: String = ""
    var suffix: String = ""
    var timerPublisher: Publishers.Autoconnect<Timer.TimerPublisher>

    @State private var timeRemaining: DateComponents = DateComponents()

    var body: some View {
        if date <= Date() {
            Text("Expired")
        } else {
            Text(prefix + formattedCountdown() + suffix)
                .font(font?.monospacedDigit())
                .onReceive(timerPublisher) { _ in
                    updateTimeRemaining()
                }
                .onAppear(perform: updateTimeRemaining)
        }
    }

    private func updateTimeRemaining() {
        timeRemaining = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: date)
    }

    private func formattedCountdown() -> String {
        DateComponentsFormatter.positionalFormatter.string(for: timeRemaining) ?? ""
    }
}

extension DateComponentsFormatter {
    static let positionalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()
}
