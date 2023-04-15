//
//  SignInView.swift
//  Censo
//
//  Created by Donald Ness on 3/25/21.
//

import SwiftUI
import Moya

struct SignInView: View {
    @Environment(\.censoApi) var censoApi

    @State private var username = ""
    @State private var isAuthenticating: Bool = false
    @State private var showingVerification = false
    @State private var currentAlert: AlertType?

    var authProvider: CensoAuthProvider
    
    enum AlertType {
        case signInError(Error)
    }

    var canSignIn: Bool {
        return !(username.isEmpty || isAuthenticating)
    }

    var deviceKey: DeviceKey? {
        if username.isEmpty {
            return nil
        }

        return SecureEnclaveWrapper.deviceKey(email: username)
    }

    var body: some View {
        NavStackWorkaround {
            VStack(spacing: 0) {
                ScrollView {
                    VStack {
                        Image("LogoColor")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 62)
                            .padding(50)

                        Text("Sign in with the account you created on the web")
                            .multilineTextAlignment(.center)
                            .padding([.leading, .trailing], 60)
                            .padding([.bottom], 20)


                        TextField(text: $username, label: {
                            Text("Email Address")
                        })
                        .onSubmit {
                            if canSignIn { signIn() }
                        }
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(Color.black)
                        .accentColor(Color.Censo.red)
                        .textFieldStyle(LightRoundedTextFieldStyle())
                        .disabled(isAuthenticating)
                        .padding()
                    }
                }

                Spacer()

                Button(action: signIn) {
                    Text(deviceKey == nil ? "Verify Email" : "Sign in")
                        .loadingIndicator(when: isAuthenticating)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(FilledButtonStyle())
                .disabled(!canSignIn)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .padding()

                NavigationLink(isActive: $showingVerification) {
                    VerificationTokenView(username: username, authProvider: authProvider)
                } label: {
                    EmptyView()
                }
            }
            .foregroundColor(.Censo.primaryForeground)
            .navigationBarHidden(true)
            .background(
                CensoBackground()
            )
            .alert(item: $currentAlert) { item in
                switch item {
                case .signInError:
                    return Alert(
                        title: Text("Sign In Error"),
                        message: Text("An error occured trying to sign you in"),
                        primaryButton: .cancel(Text("Try Again")),
                        secondaryButton: .default(Text("Sign in with Email Verification")) {
                            showingVerification = true
                        }
                    )
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private func signIn() {
        if let key = SecureEnclaveWrapper.deviceKey(email: username) {
            isAuthenticating = true

            authProvider.authenticate(.signature(email: username, deviceKey: key)) { error in
                isAuthenticating = false

                if let error = error {
                    showSignInError(error)
                }
            }
        } else {
            showingVerification = true
        }
    }

    private func showSignInError(_ error: Error) {
        currentAlert = .signInError(error)
    }
}


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
                    .textContentType(.password)
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

        authProvider.authenticate(.emailVerification(email: username, verificationToken: token)) { error in
            isAuthenticating = false

            if let error = error {
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

extension SignInView.AlertType: Identifiable {
    var id: Int {
        switch self {
        case .signInError:
            return 0
        }
    }
}

#if DEBUG
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(authProvider: CensoAuthProvider())
            .environment(\.colorScheme, .dark)

        VerificationTokenView(username: "john@hollywood.com", authProvider: CensoAuthProvider())
    }
}
#endif
