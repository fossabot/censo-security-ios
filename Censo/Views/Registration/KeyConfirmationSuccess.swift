//
//  KeyConfirmationSuccess.swift
//  Censo
//
//  Created by Ata Namvari on 2022-07-12.
//

import SwiftUI
import BIP39

struct KeyConfirmationSuccess: View {
    @Environment(\.censoApi) var censoApi

    @RemoteResult private var signers: CensoApi.SignersInfo?

    var user: CensoApi.User
    var deviceKey: DeviceKey
    var phrase: [String]
    var onSuccess: () -> Void

    var body: some View {
        Group {
            switch $signers {
            case .idle:
                CensoProgressView(text: "Registering your key with Censo...")
                    .onAppear(perform: reload)
            case .loading:
                CensoProgressView(text: "Registering your key with Censo...")
            case .failure(let error):
                RetryView(error: error, action: reload)
            case .success:
                VStack {
                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.Censo.green)
                        .background(Color.white)
                        .clipShape(Circle())
                        .padding()
                        .frame(width: 100, height: 100)

                    Text("You're all set.")
                        .font(.system(size: 26).bold())
                        .padding()

                    Spacer()

                    Button {
                        onSuccess()
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()

                    Spacer()
                        .frame(height: 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .buttonStyle(FilledButtonStyle())
        .navigationBarHidden(true)
        .background(CensoBackground())
        .foregroundColor(.Censo.primaryForeground)
    }

    private func reload() {
        do {
            let rootSeed = try Mnemonic(phrase: phrase).seed
            let privateKeys = try PrivateKeys(rootSeed: rootSeed)
            let signers = try CensoApi.SignersInfo(publicKeys: privateKeys.publicKeys, deviceKey: deviceKey)

            _signers.reload(
                using: censoApi.provider.loader(
                    for: .addWalletSigners(signers, devicePublicKey: try deviceKey.publicExternalRepresentation().base58String)
                )
            ) { error in
                if let error = error {
                    _signers.content = .failure(error)
                } else {
                    do {
                        try Keychain.saveRootSeed(rootSeed, email: user.loginName, deviceKey: deviceKey)
                    } catch {
                        _signers.content = .failure(error)
                    }
                }
            }
        } catch {
            _signers.content = .failure(error)
        }
    }
}

extension CensoApi.SignersInfo {
    init(publicKeys: PublicKeys, deviceKey: DeviceKey) throws {
        self.signers = [
            CensoApi.WalletSigner(
                publicKey: publicKeys.bitcoin,
                chain: .bitcoin
            ),
            CensoApi.WalletSigner(
                publicKey: publicKeys.ethereum,
                chain: .ethereum
            ),
            CensoApi.WalletSigner(
                publicKey: publicKeys.offchain,
                chain: .offchain
            )
        ]

        let bytes = signers
            .map(\.publicKey)
            .map { key in
                Base58.decode(key)
            }
            .flatMap {
                $0
            }

        self.signature = try deviceKey.signature(for: Data(bytes)).base64EncodedString()
        self.share = nil
    }
}

#if DEBUG
struct KeyConfirmationSuccess_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            KeyConfirmationSuccess(user: .sample, deviceKey: .sample, phrase: [], onSuccess: {})
        }
    }
}
#endif
