//
//  PenAndPaperSignInRecovery.swift
//  Censo
//
//  Created by Ata Namvari on 2022-08-23.
//

import SwiftUI
import BIP39

struct PenAndPaperSignInRecovery: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var phraseIndex: Int = 0
    @State private var typedPhrase: [String] = Array(repeating: "", count: 24)
    @State private var signingIn = false
    @State private var alert: AlertType? = nil
    @State private var typedWord: String = ""

    var email: String
    var authProvider: CensoAuthProvider
    var deviceKey: DeviceKey

    enum AlertType: Int, Identifiable {
        var id: Int { rawValue }

        case incorrectPhrase
        case couldNotSignIn
    }

    var body: some View {
        ZStack {
            VStack {
                BackButtonBar(caption: "Sign in", presentationMode: presentationMode)

                Spacer()
                    .frame(height: 10)

                Text("Enter each word of your recovery phrase to recover your key")
                    .font(.system(size: 18).bold())
                    .padding(40)
                    .foregroundColor(.white.opacity(0.8))

                Text("Enter word #")
                    .font(.system(size: 18).bold())

                Text("\(phraseIndex + 1)")
                    .font(.system(size: 78).bold())

                TextField("", text: $typedWord)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(DarkRoundedTextFieldStyle(tint: .white))
                    .padding([.trailing, .leading], 30)
                    .multilineTextAlignment(.leading)
                    .accentColor(Color.Censo.blue)
                    .focusedOnAppear()

                HStack {
                    if phraseIndex > 0 {
                        Button {
                            phraseIndex -= 1

                            typedWord = typedPhrase[phraseIndex]
                        } label: {
                            HStack {
                                Image(systemName: "arrowtriangle.left.fill")
                                Text("Previous")
                            }
                        }
                    }

                    Spacer()

                    Button {
                        if phraseIndex == 23 {
                            finish()
                        } else {
                            phraseIndex += 1

                            typedWord = typedPhrase[phraseIndex]
                        }
                    } label: {
                        HStack {
                            Text(phraseIndex == 23 ? "Finish" : "Next")
                            Image(systemName: "arrowtriangle.right.fill")
                        }
                    }
                    .disabled(typedWord.isEmpty)
                }
                .padding([.leading, .trailing], 30)
                .buttonStyle(PlainButtonStyle())
                .onChange(of: typedWord) { newValue in
                    typedPhrase[phraseIndex] = typedWord
                }

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
        .alert(item: $alert) { alert in
            switch alert {
            case .incorrectPhrase:
                return Alert(
                    title: Text("Error"),
                    message: Text("Incorrect phrase"),
                    dismissButton: .cancel(Text("Review and try again"))
                )
            case .couldNotSignIn:
                return Alert(
                    title: Text("Error"),
                    message: Text("Make sure you have the correct recovery phrase"),
                    dismissButton: .cancel(Text("Try again"))
                )
            }
        }
    }

    private func finish() {
        do {
            let rootSeed = try Mnemonic(phrase: typedPhrase.map({ $0.lowercased().trimmingCharacters(in: .whitespaces) })).seed

            signingIn = true

            authProvider.authenticate(.signature(email: email, deviceKey: deviceKey)) { error in
                signingIn = false

                if let _ = error {
                    alert = .couldNotSignIn
                } else {
                    try? Keychain.saveRootSeed(rootSeed, email: email, deviceKey: deviceKey)
                }
            }
        } catch {
            alert = .incorrectPhrase
        }
    }
}

#if DEBUG
struct PenAndPaperSignInRecovery_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PenAndPaperSignInRecovery(email: "", authProvider: CensoAuthProvider(), deviceKey: .sample)
        }
    }
}
#endif
