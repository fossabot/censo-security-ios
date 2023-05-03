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
    var registrationController: DeviceRegistrationController
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

        registrationController.recover(deviceKey: deviceKey, registeredPublicKeys: registeredPublicKeys) { result in
            recovering = false

            switch result {
            case .success(let registeredDevice):
                registrationController.completeRegistration(with: registeredDevice)
                onSuccess()
            case .failure(let error):
                showingErrorAlert = true
                self.error = error
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
//struct KeyRetrieval_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            KeyRetrieval(user: .sample, registeredPublicKeys: [], deviceKey: .sample, onSuccess: {}, authProvider: )
//        }
//    }
//}
#endif
