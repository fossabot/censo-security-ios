//
//  KeyConfirmationSuccess.swift
//  Censo
//
//  Created by Ata Namvari on 2022-07-12.
//

import SwiftUI
import BIP39
import Moya
import raygun4apple

struct KeyConfirmationSuccess: View {
    @Environment(\.censoApi) var censoApi
    
    enum RegistrationState {
        case idle
        case loading
        case failure(Error)
        case success(RegisteredDevice)
    }

    @State private var registrationState: RegistrationState = .idle

    var user: CensoApi.User
    var deviceKey: DeviceKey
    var registrationController: DeviceRegistrationController
    var phrase: [String]
    var shardingPolicy: ShardingPolicy
    var onConflict: () -> Void
    var onSuccess: () -> Void

    var body: some View {
        Group {
            switch registrationState {
            case .idle:
                VStack {
                    Spacer()

                    Text("Its time to register your keys")
                        .font(.system(size: 26).bold())
                        .padding()

                    Spacer()

                    Button {
                        reload()
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()

                    Spacer()
                        .frame(height: 20)
                }
            case .loading:
                CensoProgressView(text: "Registering your key with Censo...")
            case .failure(let error):
                RetryView(error: error, action: reload)
            case .success(let registeredDevice):
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
                        registrationController.completeRegistration(with: registeredDevice)
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

            registrationController.register(rootSeed: rootSeed, shardingPolicy: shardingPolicy, deviceKey: deviceKey) { result in
                switch result {
                case .success(let registeredDevice):
                    registrationState = .success(registeredDevice)
                case .failure(DeviceRegistrationController.RegistrationError.conflict):
                    onConflict()
                case .failure(let error):
                    registrationState = .failure(error)
                }
            }
        } catch {
            registrationState = .failure(error)
        }
    }
}

extension Array where Element == CensoApi.WalletSigner {
    var dataToSign: Data {
        let bytes = self
            .map(\.publicKey)
            .map { key in
                Base58.decode(key)
            }
            .flatMap { bytes in
                bytes
            }

        return Data(bytes)
    }
}

extension PublicKeys {
    var walletSigners: [CensoApi.WalletSigner] {
        [
            CensoApi.WalletSigner(
                publicKey: bitcoin,
                chain: .bitcoin
            ),
            CensoApi.WalletSigner(
                publicKey: ethereum,
                chain: .ethereum
            ),
            CensoApi.WalletSigner(
                publicKey: offchain,
                chain: .offchain
            )
        ]
    }
}

#if DEBUG
//struct KeyConfirmationSuccess_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            KeyConfirmationSuccess(user: .sample, deviceKey: .sample, phrase: [], shardingPolicy: .sample, onConflict: {}, onSuccess: {})
//        }
//    }
//}
#endif
