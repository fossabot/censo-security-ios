//
//  UnknownRequestRow.swift
//  Censo
//
//  Created by Ata Namvari on 2021-08-25.
//

import Foundation
import SwiftUI

import Combine

struct UnknownRequestRow: View {
    var request: ApprovalRequest
    var timerPublisher: Publishers.Autoconnect<Timer.TimerPublisher>

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Image(systemName: "questionmark")
                Text("Unknown Request")
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .allowsTightening(true)
                    .textCase(.uppercase)
                    .font(.subheadline)
                    .foregroundColor(Color.white)
                Spacer()
                if let expireDate = request.expireDate {
                    Countdown(date: expireDate, timerPublisher: timerPublisher)
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .background(Color.Censo.thirdBackground /**/)

            Text("You have an unknown approval request. Please update this app to see the request details")
                .multilineTextAlignment(.center)
                .padding()

            Divider()

            HStack(spacing: 0) {
                Button {
                    UIApplication.shared.open(URL(string: "https://apps.apple.com/us/app/censo-security-app/id1659702225")!, options: [:], completionHandler: nil)
                } label: {
                    Text("Update Censo Mobile...")
                        .bold()
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(height: 45)
        }
        .roundedCell(background: Color.Censo.secondaryBackground)
    }
}

#if DEBUG
struct UnknownRequestRow_Preivews: PreviewProvider {
    static var previews: some View {
        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        UnknownRequestRow(request: .sample, timerPublisher: timerPublisher)

    }
}
#endif
