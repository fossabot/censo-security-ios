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
    var solanaPublicKey: String
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
                .textFieldStyle(DarkRoundedTextFieldStyle(tint: incorrectPhrase ? .Censo.red : .white))
                .padding(30)
                .multilineTextAlignment(.leading)
                .accentColor(Color.Censo.blue)
                .disableAutocorrection(true)

            Spacer()
            Spacer()
            Spacer()
        }
        .multilineTextAlignment(.center)
        .buttonStyle(FilledButtonStyle())
        .navigationBarHidden(true)
        .background(CensoBackground())
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
            
            if privateKeys.publicKey(for: .solana) == solanaPublicKey {
                try Keychain.saveRootSeed(rootSeed, email: user.loginName)

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
            PasswordManagerRecovery(user: .sample, solanaPublicKey: "", onSuccess: {})
        }
    }
}
#endif