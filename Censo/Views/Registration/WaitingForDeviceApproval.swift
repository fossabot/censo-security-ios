//
//  WaitingForDeviceApproval.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-06.
//

import Foundation
import SwiftUI

struct WaitingForDeviceApproval: View {
    private let appForegroundedPublisher = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
    private let remoteNotificationPublisher = NotificationCenter.default.publisher(for: .userDidReceiveRemoteNotification)

    var onReload: () -> Void

    var body: some View {

        VStack(spacing: 30) {
            Text("Waiting for your organization administrators to authorize this device.\n\nPlease check back later.")
                .font(.callout)

        }
        .preferredColorScheme(.light)
        .foregroundColor(.Censo.primaryForeground)
        .padding(30)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color(white: 0.2), lineWidth: 1)
        )
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .buttonStyle(FilledButtonStyle())
        .background(CensoBackground())
        .foregroundColor(.Censo.primaryForeground)
        .onReceive(appForegroundedPublisher.merge(with: remoteNotificationPublisher)) { _ in
            onReload()
        }
    }
}

#if DEBUG
struct WaitingForDeviceApproval_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WaitingForDeviceApproval(onReload: { })
        }
    }
}
#endif
