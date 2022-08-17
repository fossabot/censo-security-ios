//
//  SignInView.swift
//  Strike
//
//  Created by Donald Ness on 3/25/21.
//

import SwiftUI

struct SignInView: View {
    @AppStorage("email") private var username = ""
    @State private var isAuthenticating: Bool = false
    @State private var showingPassword = false
    @State private var currentAlert: AlertType?

    var authProvider: StrikeAuthProvider
    
    enum AlertType {
        case signInError(Error)
    }

    var canSignIn: Bool {
        return !(username.isEmpty || isAuthenticating)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack {
                        Image("Logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 22)
                            .padding(50)

                        Text("Sign in with the account you created on the web")
                            .multilineTextAlignment(.center)
                            .padding([.leading, .trailing], 60)
                            .padding([.bottom], 20)

                        VStack(alignment: .leading, spacing: 20) {
                            Text("Email")

                            TextField("", text: $username) {
                                if canSignIn { signIn() }
                            }
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(Color.black)
                            .accentColor(Color.Strike.purple)
                            .textFieldStyle(LightRoundedTextFieldStyle())
                        }
                        .padding(35)
                        .background(
                            Rectangle()
                                .border(.gray.opacity(0.4), width: 1)
                                .foregroundColor(.black)
                        )
                        .padding(20)
                        .disabled(isAuthenticating)
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
                .padding(30)

                NavigationLink(isActive: $showingPassword) {
                    PasswordView(username: username, authProvider: authProvider)
                } label: {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
            .background(
                StrikeBackground()
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
    }

    private func signIn() {
        if Keychain.hasPrivateKey(email: username) {
            isAuthenticating = true

            authProvider.authenticate(.signature(email: username)) { error in
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
    var authProvider: StrikeAuthProvider

    var canSignIn: Bool {
        return !(password.isEmpty || isAuthenticating)
    }

    var body: some View {
        VStack(spacing: 0) {
            BackButtonBar(caption: "Email", presentationMode: presentationMode)
                .frame(height: 50)

            ScrollView {
                VStack {
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 22)
                        .padding([.leading, .trailing, .bottom], 50)

                    (Text("Signing in as ") + Text(username).bold())
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 60)
                        .padding([.bottom], 20)

                    VStack(alignment: .leading, spacing: 20) {
                        Text("Password")

                        SecureField("", text: $password) {
                            if canSignIn { signIn() }
                        }
                        .textContentType(.password)
                        .foregroundColor(Color.black)
                        .accentColor(Color.Strike.purple)
                        .textFieldStyle(LightRoundedTextFieldStyle())

//                        HStack {
//                            Spacer()
//
//                            Button {
//
//                            } label: {
//                                Text("Forgot password?")
//                            }
//                            .foregroundColor(.Strike.purple)
//                        }
                    }
                    .padding(35)
                    .background(
                        Rectangle()
                            .border(.gray.opacity(0.4), width: 1)
                            .foregroundColor(.black)
                    )
                    .padding(20)
                    .disabled(isAuthenticating)
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
            .padding(30)
        }
        .navigationBarHidden(true)
        .background(
            StrikeBackground()
        )
        .alert(item: $currentAlert) { item in
            switch item {
            case .signInError:
                return Alert.withDismissButton(title: Text("Sign In Error"), message: Text("Please check your username and password"))
            }
        }
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
        SignInView(authProvider: StrikeAuthProvider())

        PasswordView(username: "john@hollywood.com", authProvider: StrikeAuthProvider())
    }
}
#endif
