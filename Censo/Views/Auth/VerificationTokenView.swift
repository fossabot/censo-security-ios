//
//  VerificationTokenView.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-17.
//

import SwiftUI
import Moya

struct VerificationTokenView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.censoApi) var censoApi

    @State private var token = ""
    @State private var isAuthenticating: Bool = false
    @State private var currentAlert: AlertType?

    enum AlertType {
        case signInError(Error)
        case emailVerificationError(Error)
    }

    var username: String
    var authProvider: CensoAuthProvider

    var canSignIn: Bool {
        return !(token.isEmpty || isAuthenticating)
    }

    var body: some View {
        VStack(spacing: 0) {
            BackButtonBar(caption: "Email", presentationMode: presentationMode)
                .frame(height: 50)

            ScrollView {
                VStack {
                    Image("LogoColor")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 62)
                        .padding(50)

                    (Text("A verification code has been sent to ") + Text(username).bold())
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 60)

                    Button {
                        sendEmailVerification()
                    } label: {
                        Text("Resend Verification Code")
                            .foregroundColor(.Censo.red)
                    }
                    .disabled(isAuthenticating)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .padding([.bottom], 20)

                    TextField(text: $token, label: {
                        Text("Enter code here")
                    })
                    .onSubmit {
                        if canSignIn { signIn() }
                    }
                    .keyboardType(.numberPad)
                    .foregroundColor(Color.black)
                    .accentColor(Color.Censo.red)
                    .textFieldStyle(LightRoundedTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .disabled(isAuthenticating)
                    .padding()
                }
            }

            Spacer()

            Button(action: signIn) {
                Text("Sign in")
                    .loadingIndicator(when: isAuthenticating)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(FilledButtonStyle())
            .disabled(!canSignIn)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .padding()
        }
        .foregroundColor(.Censo.primaryForeground)
        .navigationBarHidden(true)
        .background(
            CensoBackground()
        )
        .alert(item: $currentAlert) { item in
            switch item {
            case .emailVerificationError:
                return Alert(
                    title: Text("Verification Error"),
                    message: Text("An error occured trying to send your verification code"),
                    dismissButton: .cancel(Text("Try Again"))
                )
            case .signInError:
                return Alert.withDismissButton(title: Text("Verication Error"), message: Text("Please check your verification code"))
            }
        }
        .preferredColorScheme(.light)
    }

    private func sendEmailVerification() {
        isAuthenticating = true

        censoApi.provider.request(.emailVerification(username)) { result in
            isAuthenticating = false

            switch result {
            case .success(let response) where response.statusCode < 400:
                break
            case .success(let response):
                currentAlert = .emailVerificationError(MoyaError.statusCode(response))
            case .failure(let error):
                currentAlert = .emailVerificationError(error)
            }
        }
    }

    private func signIn() {
        isAuthenticating = true

        censoApi.provider.decodableRequest(.login(.emailVerification(email: username, verificationToken: token))) { (result: Result<CensoAuthProvider.JWTToken, MoyaError>) in
            isAuthenticating = false

            switch result {
            case .success(let authToken):
                if let deviceKey = SecureEnclaveWrapper.deviceKey(email: username) {
                    authProvider.authenticatedState = .emailAuthenticated(deviceKey, token: authToken)
                } else {
                    do {
                        let deviceKey = try SecureEnclaveWrapper.generateDeviceKey(email: username)
                        authProvider.authenticatedState = .emailAuthenticated(deviceKey, token: authToken)
                    } catch {
                        showSignInError(error)
                    }
                }

            case .failure(let error):
                showSignInError(error)
            }
        }
    }

    private func showSignInError(_ error: Error) {
        currentAlert = .signInError(error)
    }
}

extension VerificationTokenView.AlertType: Identifiable {
    var id: Int {
        switch self {
        case .signInError:
            return 0
        case .emailVerificationError:
            return 1
        }
    }
}
