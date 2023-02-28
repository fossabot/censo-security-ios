//
//  PasswordManagerConfirm.swift
//  Censo
//
//  Created by Ata Namvari on 2022-07-12.
//

import SwiftUI

struct PasswordManagerConfirm: View {
    @Environment(\.presentationMode) var presentationMode

    var user: CensoApi.User
    var deviceKey: DeviceKey
    var phrase: [String]
    var onSuccess: () -> Void

    @State private var pastedPhrase: String = ""
    @State private var incorrectPhrase = false
    @State private var showingSuccess = false

    var body: some View {
        VStack {
            BackButtonBar(caption: "Copy Key", presentationMode: presentationMode)

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
                .accentColor(Color.Censo.red)
                .disableAutocorrection(true)


            Spacer()
            Spacer()
            Spacer()
        }
        .preferredColorScheme(.light)
        .multilineTextAlignment(.center)
        .buttonStyle(FilledButtonStyle())
        .navigationBarHidden(true)
        .foregroundColor(.Censo.primaryForeground)
        .background(CensoBackground())
        .onAppear {
            UIPasteboard.general.string = nil
        }
        .onChange(of: pastedPhrase) { newValue in
            let pastedWords = newValue.split(separator: " ").map(String.init)

            if pastedWords == phrase {
                incorrectPhrase = false
                showingSuccess = true
            } else {
                incorrectPhrase = true
            }
        }

        NavigationLink(isActive: .constant(showingSuccess)) {
            KeyConfirmationSuccess(user: user, deviceKey: deviceKey, phrase: phrase, onSuccess: onSuccess)
        } label: {
            EmptyView()
        }
    }
}

#if DEBUG
struct PasswordManagerConfirm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PasswordManagerConfirm(user: .sample, deviceKey: .sample, phrase: [], onSuccess: {})
        }
    }
}
#endif
