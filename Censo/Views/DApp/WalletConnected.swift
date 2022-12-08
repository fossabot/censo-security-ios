//
//  WalletConnected.swift
//  Censo
//
//  Created by Ata Namvari on 2021-12-01.
//

import SwiftUI

struct WalletConnected: View {
    @Environment(\.presentationMode) var presentationMode

    @RemoteResult private var logo: Image?

    var connectedWallet: CensoApi.ConnectedWallet

    var body: some View {
        VStack {
            Group {
                switch (connectedWallet.dappInfo.logo, $logo) {
                case (.none, _):
                    Image(systemName: "checkmark.shield.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.Censo.green)
                case (_ ,.success(let image)):
                    image
                default:
                    EmptyView()
                }
            }
            .frame(width: 100, height: 100)

            Spacer()
                .frame(height: 50)

            Text("Successfully connected to \(connectedWallet.dappInfo.name)")
                .multilineTextAlignment(.center)
                .font(.title)
                .foregroundColor(.white)
                .padding()

            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("OK")
            }
            .buttonStyle(FilledButtonStyle())
            .padding()
        }
        .onFirstTimeAppear {
            if let url = connectedWallet.dappInfo.logo {
                _logo.reload(using: ImageLoader(url: url))
            }
        }
        .background(Color.clear)
    }
}

#if DEBUG
struct WalletConnected_Previews: PreviewProvider {
    static var previews: some View {
        WalletConnected(connectedWallet: .sample)
    }
}

extension CensoApi.ConnectedWallet {
    static let sample = CensoApi.ConnectedWallet(
        dappInfo: DAppInfo(
            name: "Uniswap",
            description: "Swap or provide liquidity on the Uniswap Protocol",
            logo: URL(string: "https://app.uniswap.org/favicon.png")
        )
    )
}

#endif
