//
//  VersionCheck.swift
//  Censo
//
//  Created by Ata Namvari on 2022-08-09.
//

import SwiftUI
import Semver
import Moya

struct VersionCheck<V>: ViewModifier where V : View {
    @Environment(\.censoApi) var apiProvider

    @State private var requiresUpdate = false

    private let appForegroundedPublisher = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)

    var updateView: () -> V

    func body(content: Content) -> some View {
        Group {
            if requiresUpdate {
                updateView()
            } else {
                content
            }
        }
        .onFirstTimeAppear {
            checkForMinVersion()
        }
        .onReceive(appForegroundedPublisher) { _ in
            checkForMinVersion()
        }
    }

    private func checkForMinVersion() {
        guard let currentAppVersion = Bundle.main.appVersion else {
            return
        }

        apiProvider.provider.decodableRequest(.minVersion) { (result: Result<AppMinVersions, MoyaError>) in
            switch result {
            case .success(let apps):
                if apps.ios.minimumVersion > currentAppVersion {
                    self.requiresUpdate = true
                }
            case .failure(let error):
                RaygunClient.sharedInstance().send(error: error, tags: ["version-check"], customData: nil)
            }
        }
    }
}

struct AppMinVersions: Decodable {
    struct MinVersion: Decodable {
        let minimumVersion: Semver
    }

    let ios: MinVersion
}

extension Semver: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let versionString = try container.decode(String.self)

        try self.init(string: versionString)
    }
}

extension Bundle {
    var appVersion: Semver? {
        guard let currentVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return nil
        }

        return try? Semver(string: currentVersionString)
    }
}

extension View {
    func versionChecked<V>(@ViewBuilder updateView: @escaping () -> V) -> some View where V : View {
        modifier(VersionCheck(updateView: updateView))
    }
}
