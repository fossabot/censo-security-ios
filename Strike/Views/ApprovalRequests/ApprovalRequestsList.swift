//
//  ApprovalRequestsList.swift
//  Strike
//
//  Created by Ata Namvari on 2021-04-17.
//

import Foundation
import SwiftUI

import Combine

struct ApprovalRequestsList: View {
    var user: StrikeApi.User
    var requests: [WalletApprovalRequest]
    var onStatusChange: (() -> Void)?
    var onRefresh: (RefreshContext) -> Void

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        if #available(iOS 15, *) {
            List {
                if requests.count == 0 {
                    EmptyApprovalRequestsList()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(0..<requests.count, id: \.self) { idx in
                        ApprovalRequestItem(
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
                await withCheckedContinuation { continuation in
                    onRefresh(RefreshContext {
                        continuation.resume()
                    })
                }
            }
            .listStyle(.plain)
        } else {
            RefreshScrollView(onRefresh: onRefresh) {
                if requests.count == 0 {
                    EmptyApprovalRequestsList()
                } else {
                    LazyVStack(alignment: .center, spacing: 12) {
                        ForEach(0..<requests.count, id: \.self) { idx in
                            ApprovalRequestItem(
                                user: user,
                                request: requests[idx],
                                onStatusChange: onStatusChange,
                                timerPublisher: timer
                            )
                        }
                    }
                    .padding()
                }
            }
            .ignoresSafeArea(.all, edges: [.bottom])
        }
    }
}

#if DEBUG
struct ApprovalRequestsList_Previews: PreviewProvider {
    static var previews: some View {
        ApprovalRequestsList(user: .sample, requests: [], onStatusChange: nil) { refreshContext in
            refreshContext.endRefreshing()
        }
        .background(Color.Strike.primaryBackground.ignoresSafeArea())
    }
}
#endif
