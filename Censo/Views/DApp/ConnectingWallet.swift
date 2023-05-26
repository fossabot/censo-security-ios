//
//  ConnectingWallet.swift
//  Censo
//
//  Created by Ata Namvari on 2023-05-04.
//

import SwiftUI
import Moya

struct ConnectingWallet: View {
    @Environment(\.censoApi) var censoApi

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var attempts = 0

    @Binding var connectionState: DAppScan.ConnectionState

    var topic: String
    var wallet: CensoApi.AvailableDAppWallet
    var deviceKey: DeviceKey

    var body: some View {
        ProgressView {
            Text("Connecting \(wallet.walletName) to dApp")
        }
        .onReceive(timer) { _ in
            checkConnection()
        }
    }

    private func checkConnection() {
        guard attempts < 5 else {
            connectionState = .failed(WalletConnectError.timedOut)
            return
        }

        attempts += 1

        censoApi.provider.decodableRequest(.checkDAppConnection(topic: topic, devicePublicKey: try! deviceKey.publicExternalRepresentation().base58String)) { (result: Result<[CensoApi.WalletConnectSession], MoyaError>) in
            switch result {
            case .success(let connectSessions):
                if let activeSession = connectSessions.first(where: { $0.status == .active }) {
                    connectionState = .finished(activeSession, wallet: wallet)
                }
            case .failure(let error):
                connectionState = .failed(error)
            }
        }
    }
}

enum WalletConnectError: Error {
    case timedOut
}
