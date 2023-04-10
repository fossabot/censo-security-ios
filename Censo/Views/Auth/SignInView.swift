//
//  SignInView.swift
//  Censo
//
//  Created by Donald Ness on 3/25/21.
//

import SwiftUI

struct SignInView: View {
    @State private var username = ""
    @State private var isAuthenticating: Bool = false
    @State private var showingPassword = false
    @State private var currentAlert: AlertType?

    var authProvider: CensoAuthProvider
    
    enum AlertType {
        case signInError(Error)
    }

    var canSignIn: Bool {
        return !(username.isEmpty || isAuthenticating)
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
                    Text("Sign in")
                        .loadingIndicator(when: isAuthenticating)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(FilledButtonStyle())
                .disabled(!canSignIn)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .padding()

                NavigationLink(isActive: $showingPassword) {
                    PasswordView(username: username, authProvider: authProvider)
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
                        primaryButton: .default(Text("Use Password"), action: {
                            showingPassword = true
                        }),
                        secondaryButton: .cancel(Text("Try Again"))
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
            showingPassword = true
        }
    }

    private func showSignInError(_ error: Error) {
        currentAlert = .signInError(error)
    }
}


struct PasswordView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var password = ""
    @State private var isAuthenticating: Bool = false
    @State private var showingPassword = false
    @State private var currentAlert: AlertType?

    enum AlertType {
        case signInError(Error)
    }

    var username: String
    var authProvider: CensoAuthProvider

    var canSignIn: Bool {
        return !(password.isEmpty || isAuthenticating)
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

                    (Text("Signing in as ") + Text(username).bold())
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 60)
                        .padding([.bottom], 20)

                    SecureField(text: $password, label: {
                        Text("Password")
                    })
                    .onSubmit {
                        if canSignIn { signIn() }
                    }
                    .textContentType(.password)
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
            case .signInError:
                return Alert.withDismissButton(title: Text("Sign In Error"), message: Text("Please check your username and password"))
            }
        }
        .preferredColorScheme(.light)
    }

    private func signIn() {
        showingPassword = true

        isAuthenticating = true

        authProvider.authenticate(.password(email: username, password: password)) { error in
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

extension PasswordView.AlertType: Identifiable {
    var id: Int {
        switch self {
        case .signInError:
            return 0
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

        PasswordView(username: "john@hollywood.com", authProvider: CensoAuthProvider())
    }
}
#endif
