//
//  PasswordManagerSignInRecovery.swift
//  Censo
//
//  Created by Ata Namvari on 2022-08-23.
//

import SwiftUI
import BIP39

struct PasswordManagerSignInRecovery: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var pastedPhrase: String = ""
    @State private var incorrectPhrase = false
    @State private var signingIn = false
    @State private var showingSignInError = false

    var email: String
    var authProvider: CensoAuthProvider
    var deviceKey: DeviceKey

    var body: some View {
        ZStack {
            VStack {
                BackButtonBar(caption: "Sign in", presentationMode: presentationMode)

                Spacer()

                Text("Confirm recovery phrase")
                    .font(.system(size: 26).bold())
                    .padding()

                if !incorrectPhrase {
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
            .blur(radius: signingIn ? 5 : 0)
            .disabled(signingIn)

            if signingIn {
                CensoProgressView(text: "Signing in...")
            }
        }
        .multilineTextAlignment(.center)
        .buttonStyle(FilledButtonStyle())
        .navigationBarHidden(true)
        .background(CensoBackground())
        .alert(isPresented: $showingSignInError) {
            Alert(
                title: Text("Error"),
                message: Text("Make sure you have the correct recovery phrase"),
                dismissButton: .cancel(Text("Try again"), action: {
                    pastedPhrase = ""
                })
            )
        }
        .onChange(of: pastedPhrase) { newValue in
            signIn(phrase: newValue)
        }
    }

    private func signIn(phrase: String) {
        incorrectPhrase = false

        let pastedWords = phrase.lowercased().split(separator: " ").map(String.init)

        guard pastedWords.count == 24 else {
            return
        }
        do {
            let rootSeed = try Mnemonic(phrase: pastedWords).seed

            signingIn = true

            authProvider.authenticate(.signature(email: email, deviceKey: deviceKey)) { error in
                signingIn = false

                if let _ = error {
                    showingSignInError = true
                } else {
                    try? Keychain.saveRootSeed(rootSeed, email: email, deviceKey: deviceKey)
                }
            }
        } catch {
            incorrectPhrase = true
        }
    }
}

#if DEBUG
struct PasswordManagerSignInRecovery_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PasswordManagerSignInRecovery(email: "", authProvider: CensoAuthProvider(), deviceKey: .sample)
        }
    }
}
#endif
