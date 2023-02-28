//
//  PasswordManagerRecovery.swift
//  Censo
//
//  Created by Ata Namvari on 2022-07-13.
//

import SwiftUI
import BIP39

struct PasswordManagerRecovery: View {
    @Environment(\.presentationMode) var presentationMode

    var user: CensoApi.User
    var registeredPublicKeys: [CensoApi.PublicKey]
    var deviceKey: DeviceKey
    var onSuccess: () -> Void

    @State private var pastedPhrase: String = ""
    @State private var incorrectPhrase = false
    @State private var showingSuccess = false
    @State private var showingKeySaveErrorAlert = false

    var body: some View {
        VStack {
            BackButtonBar(caption: "Start over", presentationMode: presentationMode)

            Spacer()

            Text("Confirm recovery phrase")
                .font(.system(size: 26).bold())
                .padding()

            if !incorrectPhrase {
                Text("We've cleared your clipboard.")
                    .padding([.leading, .trailing], 50)
                    .padding([.top, .bottom], 10)

                Text("Open your Password Manager, copy your recovery phrase, and paste it here.")
                    .padding([.leading, .trailing], 50)
                    .padding([.top, .bottom], 10)
            } else {
                Text("Uh oh.  That recovery phrase is not correct.")
                    .padding([.leading, .trailing], 50)
                    .padding([.top, .bottom], 10)

                Text("You can try again or go back to copy your recovery phrase.")
                    .padding([.leading, .trailing], 50)
                    .padding([.top, .bottom], 10)
            }

            SecureField("", text: $pastedPhrase)
                .textFieldStyle(.roundedBorder)
                .foregroundColor(incorrectPhrase ? .red : .Censo.primaryForeground)
                .padding()
                .multilineTextAlignment(.leading)
                .accentColor(Color.Censo.blue)
                .disableAutocorrection(true)

            Spacer()
            Spacer()
            Spacer()
        }
        .preferredColorScheme(.light)
        .multilineTextAlignment(.center)
        .buttonStyle(FilledButtonStyle())
        .navigationBarHidden(true)
        .background(CensoBackground())
        .foregroundColor(.Censo.primaryForeground)
        .onAppear {
            UIPasteboard.general.string = nil
        }
        .alert(isPresented: $showingKeySaveErrorAlert) {
            Alert(
                title: Text("Something went wrong"),
                message: Text("Could not save your private key to keychain"),
                primaryButton: .default(Text("Try again"), action: {
                    savePrivateKeys(phrase: pastedPhrase)
                }),
                secondaryButton: .cancel(Text("Cancel"), action: {
                    pastedPhrase = ""
                })
            )
        }
        .onChange(of: pastedPhrase) { newValue in
            savePrivateKeys(phrase: newValue)
        }

        NavigationLink(isActive: .constant(showingSuccess)) {
            KeyRecoverySuccess(onSuccess: onSuccess)
        } label: {
            EmptyView()
        }
    }

    private func savePrivateKeys(phrase: String) {
        incorrectPhrase = false

        let pastedWords = phrase.lowercased().split(separator: " ").map(String.init)

        guard pastedWords.count == 24 else {
            return
        }

        do {
            let rootSeed = try Mnemonic(phrase: pastedWords).seed
            let privateKeys = try PrivateKeys(rootSeed: rootSeed)
            
            if privateKeys.publicKeys.matches(anyOf: registeredPublicKeys) {
                try Keychain.saveRootSeed(rootSeed, email: user.loginName, deviceKey: deviceKey)

                showingSuccess = true
            } else {
                incorrectPhrase = true
            }
        } catch Keychain.KeychainError.couldNotSave {
            showingKeySaveErrorAlert = true
        } catch {
            incorrectPhrase = true
        }
    }
}

#if DEBUG
struct PasswordManagerRecovery_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PasswordManagerRecovery(user: .sample, registeredPublicKeys: [], deviceKey: .sample, onSuccess: {})
        }
    }
}
#endif
