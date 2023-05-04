//
//  WalletSession.swift
//  Censo
//
//  Created by Ata Namvari on 2021-12-01.
//

import SwiftUI

struct WalletSession: View {
    @Environment(\.dismiss) var dismiss

    var walletConnectSession: CensoApi.WalletConnectSession
    var onTryAgain: () -> Void

    var body: some View {
        switch walletConnectSession.status {
        case .active:
            VStack {
                Group {
                    if let iconURL = walletConnectSession.icons.first.flatMap({ URL(string: $0) }) {
                        AsyncImage(url: iconURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Image(systemName: "checkmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.Censo.green)
                    }
                }
                .frame(width: 100, height: 100)

                Spacer()
                    .frame(height: 50)

                Text("Successfully connected to \(walletConnectSession.name)")
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .padding()

                Button {
                    dismiss()
                } label: {
                    Text("OK")
                }
                .buttonStyle(FilledButtonStyle())
                .padding()
            }
            .background(Color.clear)
        default:
            VStack {
                Text(walletConnectSession.status.rawValue)

                Button {
                    onTryAgain()
                } label: {
                    Text("Try Again")
                }
            }
        }

    }
}

#if DEBUG
struct WalletConnected_Previews: PreviewProvider {
    static var previews: some View {
        WalletSession(walletConnectSession: .sample, onTryAgain: { })
    }
}

extension CensoApi.WalletConnectSession {
    static let sample = CensoApi.WalletConnectSession(
        topic: "topic",
        name: "Uniswap",
        url: "",
        description: "Swap or provide liquidity on the Uniswap Protocol",
        icons: [
            "https://app.uniswap.org/favicon.png"
        ],
        status: .active,
        wallets: []
    )
}

#endif
