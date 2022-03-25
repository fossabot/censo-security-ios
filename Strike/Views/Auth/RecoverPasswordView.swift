//
//  ResetPasswordView.swift
//  Strike
//
//  Created by Donald Ness on 3/27/21.
//

import SwiftUI
import OktaAuthNative

struct RecoverPasswordView: View {
    @Environment(\.presentationMode) var presentation
    
    @Binding var username: String
    
    @State private var nextStatus: OktaAuthStatus? = nil
    @State private var isLoading: Bool = false
    
    enum AlertType {
        case recoverPasswordError(Error)
    }

    @State private var currentAlert: AlertType?
    
    var body: some View {
        VStack {
            switch nextStatus {
            case .none:
                VStack {
                    Spacer()
                    
                    Text("Enter the email address associated with your account.")
                        .padding()
                    
                    TextField("Email", text: $username)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(Color.white)
                        .accentColor(Color.Strike.purple)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isLoading)
                        .padding()
                    
                    Spacer()

                    Button(action: recoverPassword) {
                        Text("Reset via Email")
                            .loadingIndicator(when: isLoading)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(FilledButtonStyle())
                    .disabled(username.isEmpty || isLoading)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .padding()
                }
            case let recoveryChallengeStatus as OktaAuthStatusRecoveryChallenge:
                RecoverPasswordChallengeView(status: recoveryChallengeStatus)
            case .some(let unsupportedStatus):
                UnsupportedAuthStatusView(status: unsupportedStatus)
            }
        }
        .background(
            Color.Strike.primaryBackground
                .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Password Reset")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: close) {
                    Image(systemName: "xmark")
                }
                .foregroundColor(.white)
            }
        }
        .alert(item: $currentAlert) { item in
            switch item {
            case .recoverPasswordError:
                return Alert.withDismissButton(title: Text("Reset Password Error"), message: Text("Could not reset your password"))
            }
        }
    }
    
    private func recoverPassword() {
        isLoading = true
        OktaAuthSdk.recoverPassword(
            with: Configuration.oktaDomain,
            username: username,
            factorType: OktaRecoveryFactors.email,
            onStatusChange: { status in
                isLoading = false
                nextStatus = status
            },
            onError: { error in
                isLoading = false
                currentAlert = .recoverPasswordError(error)
            }
        )
    }
    
    private func close() {
        presentation.wrappedValue.dismiss()
    }
}

extension RecoverPasswordView.AlertType: Identifiable {
    var id: Int {
        switch self {
        case .recoverPasswordError:
            return 0
        }
    }
}

#if DEBUG
struct RecoverPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        RecoverPasswordView(username: .constant(""))
    }
}
#endif
