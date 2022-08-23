//
//  KeyRetrievalSignInRecovery.swift
//  Strike
//
//  Created by Ata Namvari on 2022-08-23.
//

import Foundation
import SwiftUI

struct KeyRetrievalSignInRecovery: View {
    @Environment(\.presentationMode) var presentationMode

    var email: String
    var authProvider: StrikeAuthProvider

    var body: some View {
        VStack {
            BackButtonBar(caption: "Sign in", presentationMode: presentationMode)

            Spacer()

            Image(systemName: "key")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
                .padding(40)

            Text("It's time to restore your private key using your secret recovery phrase")
                .font(.system(size: 26).bold())
                .multilineTextAlignment(.center)
                .padding(20)

            Text("How did you back it up?")
                .padding()

            NavigationLink {
                PasswordManagerSignInRecovery(email: email, authProvider: authProvider)
            } label: {
                Text("Password Manager")
                    .frame(maxWidth: .infinity)
            }
            .padding([.leading, .trailing], 30)
            .padding([.top, .bottom])

            NavigationLink {
                PenAndPaperSignInRecovery(email: email, authProvider: authProvider)
            } label: {
                Text("Pen and Paper")
                    .frame(maxWidth: .infinity)
            }
            .padding([.leading, .trailing], 30)

            Spacer()
        }
        .buttonStyle(FilledButtonStyle())
        .navigationBarHidden(true)
        .background(StrikeBackground())
    }
}

#if DEBUG
struct KeyRetrievalSignInRecovery_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            KeyRetrievalSignInRecovery(email: "", authProvider: StrikeAuthProvider())
        }
    }
}
#endif
