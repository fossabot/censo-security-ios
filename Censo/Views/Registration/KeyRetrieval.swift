//
//  KeyRetrieval.swift
//  Censo
//
//  Created by Ata Namvari on 2022-03-02.
//

import Foundation
import SwiftUI
import raygun4apple

struct KeyRetrieval: View {
    @Environment(\.censoApi) var censoApi

    @RemoteResult private var recoveryShardsResponse: CensoApi.RecoveryShardsResponse?

    var user: CensoApi.User
    var registeredPublicKeys: [CensoApi.PublicKey]
    var deviceKey: DeviceKey
    var onSuccess: () -> Void

    var body: some View {
        Group {
            switch $recoveryShardsResponse {
            case .idle:
                CensoProgressView(text: "Loading your recovery...")
                    .onAppear(perform: reload)
            case .loading:
                CensoProgressView(text: "Loading your recovery...")
            case .success(let response):
                VStack {
                    Spacer()

                    Image(systemName: "key")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                        .padding(40)

                    Text("It's time to restore your private key")
                        .font(.system(size: 26).bold())
                        .multilineTextAlignment(.center)
                        .padding(20)

                    Button {
                        recover(response: response)
                    } label: {
                        Text("Recover")
                            .frame(maxWidth: .infinity)
                    }
                    .padding([.leading, .trailing], 30)

                    Spacer()
                }
            case .failure(let error):
                RetryView(error: error, action: reload)
            }
        }
        .buttonStyle(FilledButtonStyle())
        .background(CensoBackground())
        .foregroundColor(.Censo.primaryForeground)
    }

    var loader: MoyaLoader<CensoApi.RecoveryShardsResponse, CensoApi.Target> {
        MoyaLoader(provider: censoApi.provider, target: .recoveryShards(deviceIdentifier: try! deviceKey.publicExternalRepresentation().base58String))
    }

    private func reload() {
        _recoveryShardsResponse.reload(using: loader)
    }

    func recover(response: CensoApi.RecoveryShardsResponse) {
        AuthenticatedKeys.withAuhenticatedKeys(from: user.loginName) { result in
            switch result {
            case .success(let keys):
                do {
                    let recoveredRootSeed = try ShardRecovery.recoverRootSeed(recoverShardResponse: response, deviceKey: keys.deviceKey, bootstrapKey: keys.bootstrapKey)
                    try registeredPublicKeys.validateRootSeed(recoveredRootSeed)
                    try Keychain.saveRootSeed(recoveredRootSeed, email: user.loginName, deviceKey: deviceKey)

                    onSuccess()
                } catch {
                    RaygunClient.sharedInstance().send(error: error, tags: ["recovery-error"], customData: nil)

                    _recoveryShardsResponse.content = .failure(error)
                }
            case .failure(let error):
                _recoveryShardsResponse.content = .failure(error)
            }
        }
    }
}

extension Array where Element == CensoApi.PublicKey {
    enum RootSeedValidationError: Error {
        case publicKeysDontMatch
    }

    func validateRootSeed(_ rootSeed: [UInt8]) throws {
        let privateKeys = try PrivateKeys(rootSeed: rootSeed)

        for publicKey in self {
            let chainKey = privateKeys.publicKey(for: publicKey.chain)

            if publicKey.key != chainKey {
                throw RootSeedValidationError.publicKeysDontMatch
            }
        }
    }
}

#if DEBUG
struct KeyRetrieval_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            KeyRetrieval(user: .sample, registeredPublicKeys: [], deviceKey: .sample, onSuccess: {})
        }
    }
}
#endif
