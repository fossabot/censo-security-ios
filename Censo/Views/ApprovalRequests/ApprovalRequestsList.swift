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
    var deviceSigner: DeviceSigner
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
            } else {
                ForEach(0..<requests.count, id: \.self) { idx in
                    ApprovalRequestItem(
                        deviceSigner: deviceSigner,
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
            }
        }
        .refreshable {
            await onRefresh()
        }
        .listStyle(.plain)
    }
}

#if DEBUG
struct ApprovalRequestsList_Previews: PreviewProvider {
    static var previews: some View {
        ApprovalRequestsList(deviceSigner: DeviceSigner(deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, requests: [], onStatusChange: nil) { 
        }
        .background(Color.Censo.primaryBackground.ignoresSafeArea())
    }
}
#endif
