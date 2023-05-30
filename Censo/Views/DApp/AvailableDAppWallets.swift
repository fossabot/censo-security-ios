//
//  AvailableDAppWallets.swift
//  Censo
//
//  Created by Ata Namvari on 2023-05-26.
//

import SwiftUI
import Moya

struct AvailableDAppWallets: View {
    @Environment(\.censoApi) var censoApi

    @RemoteResult private var response: CensoApi.AvailableDAppVaultsResponse?

    var code: String
    var deviceKey: DeviceKey

    @Binding var connectionState: DAppScan.ConnectionState

    var body: some View {
        Group {
            switch $response {
            case .idle:
                ProgressView("Fetching available wallets...")
                    .onAppear(perform: reload)
            case .loading:
                ProgressView("Fetching available wallets...")
            case .success(let response):
                AvailableDAppWalletList(response: response, code: code, deviceKey: deviceKey, connectionState: _connectionState)
            case .failure(let error):
                RetryView(error: error, action: reload)
            }
        }
        .preferredColorScheme(.light)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Censo.primaryBackground.ignoresSafeArea())
    }

    var loader: MoyaLoader<CensoApi.AvailableDAppVaultsResponse, CensoApi.Target> {
        MoyaLoader(provider: censoApi.provider, target: .availableDAppVaults(devicePublicKey: try! deviceKey.publicExternalRepresentation().base58String))
    }

    private func reload() {
        _response.reload(using: loader)
    }
}

struct AvailableDAppWalletList: View {
    @Environment(\.censoApi) var censoApi
    @Environment(\.dismiss) var dismiss

    var response: CensoApi.AvailableDAppVaultsResponse
    var code: String
    var deviceKey: DeviceKey

    @Binding var connectionState: DAppScan.ConnectionState

    @State private var selectedWalletAddress: String?
    @State private var alert: AlertType? = nil

    enum AlertType {
        case error(Error)
    }

    var body: some View {
        Group {
            if response.vaults.count == 0 {
                Text("You do not have any dapp-enabled wallets")
            } else {
                List {
                    ForEach(0..<response.vaults.count, id: \.self) { i in
                        let vault = response.vaults[i]

                        Section {
                            ForEach(0..<vault.wallets.count, id: \.self) { j in
                                let wallet = vault.wallets[j]

                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text(wallet.walletName)

                                            Text("(\(wallet.walletAddress.masked()))")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }

                                        Text(wallet.chains.map(\.rawValue).map(\.capitalized).joined(separator: ", "))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    Button {
                                        connect(to: wallet)
                                    } label: {
                                        ZStack {
                                            if selectedWalletAddress == wallet.walletAddress {
                                                ProgressView()
                                                    .tint(.white)
                                            } else {
                                                Text("Connect")
                                            }
                                        }
                                    }
                                    .buttonStyle(FilledButtonStyle())
                                    .disabled(selectedWalletAddress != nil)
                                }
                            }
                        } header: {
                            Text(vault.vaultName)
                        }
                    }
                }
                .onAppear {
                    if response.vaults.count == 1 && response.vaults[0].wallets.count == 1 {
                        connect(to: response.vaults[0].wallets[0])
                    }
                }
            }
        }
        .alert(item: $alert) { alert in
            switch alert {
            case .error(let connectionError as CensoApi.WalletConnectionError):
                return Alert(
                    title: Text("Error"),
                    message: Text(connectionError.errors.first?.message ?? "Could not connect wallet"),
                    dismissButton: .cancel(Text("Ok"))
                )
            case .error:
                return Alert(
                    title: Text("Error"),
                    message: Text("Something went wrong"),
                    dismissButton: .cancel(Text("Ok"))
                )
            }
        }
        .navigationTitle(Text("Select Wallet"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
                .disabled(selectedWalletAddress != nil)
            }
        }
    }

    private func connect(to wallet: CensoApi.AvailableDAppWallet) {
        selectedWalletAddress = wallet.walletAddress
        
        let request = CensoApi.WalletConnectPairingRequest(uri: code, walletAddresses: [wallet.walletAddress])

        censoApi.provider.decodableRequest(.connectDApp(request, devicePublicKey: try! deviceKey.publicExternalRepresentation().base58String)) { (result: Result<CensoApi.WalletConnectPairing, MoyaError>) in
            switch result {
            case .failure(let error):
                alert = .error(error)
                connectionState = .idle
            case .success(let pairingResponse):
                connectionState = .connecting(topic: pairingResponse.topic, wallet: wallet)
            }
        }
    }
}

extension AvailableDAppWalletList.AlertType: Identifiable {
    var id: String {
        switch self {
        case .error(let error):
            return error.localizedDescription
        }
    }
}

#if DEBUG
struct AvailableDAppWallets_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AvailableDAppWalletList(response: .sample, code: "", deviceKey: .sample, connectionState: .constant(.validating(code: "")))
        }
    }
}

extension CensoApi.AvailableDAppVaultsResponse {
    static var sample: Self {
        CensoApi.AvailableDAppVaultsResponse(vaults: [
            .sample,
            .sample
        ])
    }
}

extension CensoApi.AvailableDAppVault {
    static var sample: Self {
        CensoApi.AvailableDAppVault(vaultName: "Test Vault", wallets: [.sample, .sample])
    }
}

extension CensoApi.AvailableDAppWallet {
    static var sample: Self {
        CensoApi.AvailableDAppWallet(walletName: "Test Wallet", walletAddress: "98765gfdg6ffg87sfdg6g7sfgdfgdf", chains: [.bitcoin, .ethereum])
    }
}
#endif
