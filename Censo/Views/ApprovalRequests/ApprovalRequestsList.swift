//
//  ApprovalRequestsList.swift
//  Censo
//
//  Created by Ata Namvari on 2021-04-17.
//

import Foundation
import SwiftUI

import Combine

struct ApprovalRequestsList: View {
    var registeredDevice: RegisteredDevice
    var user: CensoApi.User
    var requests: [ApprovalRequest]
    var onStatusChange: (() -> Void)?
    var onRefresh: () async -> Void

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        List {
            if requests.count == 0 {
                EmptyApprovalRequestsList()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.Censo.primaryBackground)
            } else {
                ForEach(0..<requests.count, id: \.self) { idx in
                    ApprovalRequestItem(
                        registeredDevice: registeredDevice,
                        user: user,
                        request: requests[idx],
                        onStatusChange: onStatusChange,
                        timerPublisher: timer
                    )
                    .padding([.bottom], idx == requests.count - 1 ? 10 : 0)
                    .padding([.top], idx == 0 ? 10 : 0)
                }
                .listRowSeparator(.hidden)
                .buttonStyle(BorderlessButtonStyle())
                .listRowBackground(Color.Censo.primaryBackground)
            }
        }
        .refreshable {
            await onRefresh()
        }
        .listStyle(.plain)
        .foregroundColor(.Censo.primaryForeground)
        .preferredColorScheme(.light)
        .backwardsCompatibleBackgroundColor(.Censo.primaryBackground)
    }
}

extension View {
    @ViewBuilder
    func backwardsCompatibleBackgroundColor(_ color: Color) -> some View {
        if #available(iOS 16, *) {
            background(color).scrollContentBackground(Visibility.hidden)
        } else {
            self
        }
    }
}

#if DEBUG
//struct ApprovalRequestsList_Previews: PreviewProvider {
//    static var previews: some View {
//        ApprovalRequestsList(registeredDevice: RegisteredDevice(email: "test@test.com", deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, requests: [], onStatusChange: nil) {
//        }
//        .background(Color.Censo.primaryBackground.ignoresSafeArea())
//    }
//}
#endif
