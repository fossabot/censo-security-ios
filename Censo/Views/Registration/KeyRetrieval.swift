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

    @State private var showingErrorAlert = false
    @State private var error: Error? = nil
    @State private var recovering = false

    var user: CensoApi.User
    var registeredPublicKeys: [CensoApi.PublicKey]
    var deviceKey: DeviceKey
    var authProvider: CensoAuthProvider
    var onSuccess: () -> Void

    var body: some View {
        VStack {
            Spacer()

            Image(systemName: "key")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
                .padding(40)

            Text("It's time to recover your private key")
                .font(.system(size: 26).bold())
                .multilineTextAlignment(.center)
                .padding(20)

            Button {
                recover()
            } label: {
                Text("Recover")
                    .frame(maxWidth: .infinity)
            }
            .padding([.leading, .trailing], 30)
            .disabled(recovering)

            Spacer()
        }
        .buttonStyle(FilledButtonStyle())
        .background(CensoBackground())
        .foregroundColor(.Censo.primaryForeground)
        .alert("Error", isPresented: $showingErrorAlert, presenting: error, actions: { _ in
            Button("Ok", action: {})
        }, message: { error in
            Text("There was an error trying to recover your private key: \(error.localizedDescription)")
        })
    }

    func recover() {
        recovering = true

        AuthenticatedKeys.withAuhenticatedKeys(from: user.loginName) { result in
            switch result {
            case .success(let keys):
                do {
                    try await authProvider.exchangeTokenIfNeeded(deviceKey: keys.deviceKey)

                    let response: CensoApi.RecoveryShardsResponse = try await censoApi.provider.request(.recoveryShards(deviceIdentifier: try! deviceKey.publicExternalRepresentation().base58String))
                    let recoveredRootSeed = try ShardRecovery.recoverRootSeed(recoverShardResponse: response, deviceKey: keys.deviceKey, bootstrapKey: keys.bootstrapKey)
                    try registeredPublicKeys.validateRootSeed(recoveredRootSeed)
                    try Keychain.saveRootSeed(recoveredRootSeed, email: user.loginName, deviceKey: deviceKey)

                    onSuccess()
                } catch {
                    RaygunClient.sharedInstance().send(error: error, tags: ["recovery-error"], customData: nil)

                    showingErrorAlert = true
                    self.error = error
                }
            case .failure(let error):
                showingErrorAlert = true
                self.error = error
            }

            recovering = false
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
//struct KeyRetrieval_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            KeyRetrieval(user: .sample, registeredPublicKeys: [], deviceKey: .sample, onSuccess: {}, authProvider: )
//        }
//    }
//}
#endif
