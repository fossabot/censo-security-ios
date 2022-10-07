//
//  PasswordManagerSignInRecovery.swift
//  Strike
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
    var authProvider: StrikeAuthProvider

    var body: some View {
        ZStack {
            VStack {
                BackButtonBar(caption: "Sign in", presentationMode: presentationMode)

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
                    .textFieldStyle(DarkRoundedTextFieldStyle(tint: incorrectPhrase ? .Strike.red : .white))
                    .padding(30)
                    .multilineTextAlignment(.leading)
                    .accentColor(Color.Strike.purple)
                    .disableAutocorrection(true)

                Spacer()
                Spacer()
                Spacer()
            }
            .blur(radius: signingIn ? 5 : 0)
            .disabled(signingIn)

            if signingIn {
                StrikeProgressView(text: "Signing in...")
            }
        }
        .multilineTextAlignment(.center)
        .buttonStyle(FilledButtonStyle())
        .navigationBarHidden(true)
        .background(StrikeBackground())
        .onAppear {
            UIPasteboard.general.string = nil
        }
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
            let privateKeys = try PrivateKeys.fromRootSeed(rootSeed: rootSeed)

            signingIn = true

            authProvider.authenticate(.signature(email: email, privateKey: privateKeys.solana)) { error in
                signingIn = false

                if let _ = error {
                    showingSignInError = true
                } else {
                    try? Keychain.saveRootSeed(rootSeed, email: email)
                    try? Keychain.savePrivateKeys(privateKeys, email: email)
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
            PasswordManagerSignInRecovery(email: "", authProvider: StrikeAuthProvider())
        }
    }
}
#endif
