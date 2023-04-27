//
//  ApprovalRequestsView.swift
//  Censo
//
//  Created by Ata Namvari on 2021-04-05.
//

import Foundation
import SwiftUI
import raygun4apple

struct ApprovalRequestsView: View {
    @Environment(\.censoApi) var censoApi

    @State private var didShowApprovalRequests = false

    @RemoteResult private var approvalRequests: [GracefullyDecoded<ApprovalRequest>]?

    var registeredDevice: RegisteredDevice
    var user: CensoApi.User

    private let appForegroundedPublisher = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
    private let remoteNotificationPublisher = NotificationCenter.default.publisher(for: .userDidReceiveRemoteNotification)

    var body: some View {
        Group {
            switch $approvalRequests {
            case .idle:
                ProgressView("Fetching requests...")
                    .onAppear(perform: reload)
            case .loading:
                ProgressView("Fetching requests...")
            case .success(let requests):
                ApprovalRequestsList(registeredDevice: registeredDevice, user: user, requests: requests.compactMap(\.underlying) , onStatusChange: reload, onRefresh: refresh)
                    .onAppear(perform: approvalRequestsDidAppear)
                    .onReceive(appForegroundedPublisher) { _ in
                        approvalRequestsDidAppear()
                    }
                    .onReceive(remoteNotificationPublisher) { _ in
                        approvalRequestsDidAppear()
                    }
            case .failure(let error):
                RetryView(error: error, action: reload)
            }
        }
        .preferredColorScheme(.light)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Censo.primaryBackground.ignoresSafeArea())
    }

    private var loader: MoyaLoader<[GracefullyDecoded<ApprovalRequest>], CensoApi.Target> {
        censoApi.provider.loader(for: .approvalRequests(devicePublicKey: try! registeredDevice.devicePublicKey()))
    }

    private func reload() {
        _approvalRequests.reload(using: loader)

        NotificationCenter.default.post(name: .didReloadApprovals, object: nil)
    }

    private func approvalRequestsDidAppear() {
        guard didShowApprovalRequests else {
            didShowApprovalRequests = true
            return
        }

        _approvalRequests.reload(using: loader, silent: true)

        NotificationCenter.default.post(name: .didReloadApprovals, object: nil)
    }

    private func refresh() async {
        await withCheckedContinuation { continuation in
            _approvalRequests.reload(using: loader, silent: true) { _ in
                continuation.resume()
            }
        }

        NotificationCenter.default.post(name: .didReloadApprovals, object: nil)
    }
}

#if DEBUG
//struct ApprovalRequestsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ApprovalRequestsView(registeredDevice: RegisteredDevice(email: "test@test.com", deviceKey: .sample, encryptedRootSeed: Data()), user: .sample)
//                .navigationTitle("Approvals")
//        }
//        .withMessageSupport()
//    }
//}
#endif

extension Notification.Name {
    static let didReloadApprovals = Notification.Name("didReloadApprovals")
}

enum GracefullyDecoded<T>: Decodable where T : Decodable {
    case success(T)
    case failed(Error)

    init(from decoder: Decoder) throws {
        do {
            let t = try T.init(from: decoder)
            self = .success(t)
        } catch {
            RaygunClient.sharedInstance().send(error: error, tags: ["BadApprovalRequest"], customData: nil)
            self = .failed(error)
        }
    }
}

extension GracefullyDecoded {
    var underlying: T? {
        switch self {
        case .failed:
            return nil
        case .success(let t):
            return t
        }
    }
}
