//
//  Maintenance.swift
//  Censo
//
//  Created by Ata Namvari on 2023-05-09.
//

import SwiftUI

struct Maintenance: View {
    @State private var timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeRemaining: DateComponents = DateComponents(minute: 5)

    var pollAction: () -> Void

    var body: some View {
        VStack {
            Text("Censo is under maintenance")
                .bold()

            Text("Refreshing in \(formattedCountdown())")
                .font(.caption.monospacedDigit())

            Button {
                pollAction()
            } label: {
                Text("Refresh Now")
            }
            .buttonStyle(FilledButtonStyle())
        }
        .onReceive(timerPublisher) { _ in
            updateTimeRemaining()
        }
    }

    private func formattedCountdown() -> String {
        DateComponentsFormatter.minutesSecondsFormatter.string(for: timeRemaining) ?? ""
    }

    private func updateTimeRemaining() {
        timeRemaining.second = (timeRemaining.second ?? 0) - 1

        if timeRemaining.second == -((timeRemaining.minute ?? 0) * 60) {
            pollAction()
            timeRemaining.second = nil
        }
    }
}


extension DateComponentsFormatter {
    static let minutesSecondsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()
}
