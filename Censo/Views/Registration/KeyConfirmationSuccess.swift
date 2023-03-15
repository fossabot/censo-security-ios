//
//  KeyConfirmationSuccess.swift
//  Censo
//
//  Created by Ata Namvari on 2022-07-12.
//

import SwiftUI
import BIP39
import Moya

struct KeyConfirmationSuccess: View {
    @Environment(\.censoApi) var censoApi
    
    enum RegistrationState {
        case idle
        case loading
        case failure(Error)
        case success
    }

    @State private var registrationState: RegistrationState = .idle

    var user: CensoApi.User
    var deviceKey: DeviceKey
    var phrase: [String]
    var onSuccess: () -> Void

    var body: some View {
        Group {
            switch registrationState {
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
        registrationState = .loading
        do {
            let rootSeed = try Mnemonic(phrase: phrase).seed
            let privateKeys = try PrivateKeys(rootSeed: rootSeed)
            let signers = try CensoApi.SignersInfo(publicKeys: privateKeys.publicKeys, deviceKey: deviceKey)
            
            censoApi.provider.request(.addWalletSigners(signers, devicePublicKey: try deviceKey.publicExternalRepresentation().base58String)) { result in
                switch result {
                case .failure(let error):
                    registrationState = .failure(error)
                case .success(let response) where response.statusCode >= 400:
                    registrationState = .failure(MoyaError.statusCode(response))
                case .success:
                    do {
                        try Keychain.saveRootSeed(rootSeed, email: user.loginName, deviceKey: deviceKey)
                        registrationState = .success
                    } catch {
                        registrationState = .failure(error)
                    }
                }
            }
        } catch {
            registrationState = .failure(error)
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
