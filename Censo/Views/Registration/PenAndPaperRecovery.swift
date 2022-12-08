//
//  PenAndPaperRecovery.swift
//  Censo
//
//  Created by Ata Namvari on 2022-07-13.
//

import SwiftUI
import BIP39

struct PenAndPaperRecovery: View {
    @Environment(\.presentationMode) var presentationMode

    var user: CensoApi.User
    var solanaPublicKey: String
    var onSuccess: () -> Void

    @State private var phraseIndex: Int = 0
    @State private var typedPhrase: [String] = Array(repeating: "", count: 24)
    @State private var showingSuccess = false
    @State private var alert: AlertType? = nil

    @State private var typedWord: String = ""

    enum AlertType: Int, Identifiable {
        var id: Int { rawValue }

        case incorrectPhrase
        case couldNotSave
    }

    var body: some View {
        VStack {
            BackButtonBar(caption: "Start over", presentationMode: presentationMode)

            Spacer()
                .frame(maxHeight: 50)

            Text("Enter each word of your recovery phrase to restore your key")
                .font(.system(size: 18).bold())
                .padding([.leading, .trailing], 40)
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
                .frame(maxHeight: 40)

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
                .accentColor(Color.Censo.purple)
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
            case .couldNotSave:
                return Alert(
                    title: Text("Something went wrong"),
                    message: Text("Could not save your private key to keychain"),
                    primaryButton: .default(Text("Try again"), action: {
                        finish()
                    }),
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
        }

        NavigationLink(isActive: .constant(showingSuccess)) {
            KeyRecoverySuccess(onSuccess: onSuccess)
        } label: {
            EmptyView()
        }
    }

    private func finish() {
        do {
            let rootSeed = try Mnemonic(phrase: typedPhrase.map({ $0.lowercased().trimmingCharacters(in: .whitespaces) })).seed
            let privateKeys = try PrivateKeys(rootSeed: rootSeed)

            if privateKeys.publicKey(for: .solana) == solanaPublicKey {
                try Keychain.saveRootSeed(rootSeed, email: user.loginName)

                showingSuccess = true
            } else {
                alert = .incorrectPhrase
            }
        } catch Keychain.KeychainError.couldNotSave {
            alert = .couldNotSave
        } catch {
            alert = .incorrectPhrase
        }
    }
}

#if DEBUG
struct PenAndPaperRecovery_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PenAndPaperRecovery(user: .sample, solanaPublicKey: "", onSuccess: {})
        }
    }
}
#endif
