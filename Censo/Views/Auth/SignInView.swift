//
//  SignInView.swift
//  Censo
//
//  Created by Donald Ness on 3/25/21.
//

import SwiftUI
import Moya
import LocalAuthentication

struct SignInView: View {
    @Environment(\.censoApi) var censoApi

    @AppStorage("email") private var username = ""
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

    private func signIn() {
        if let deviceKey = SecureEnclaveWrapper.deviceKey(email: username) {
            let context = LAContext()
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Verify your identity") { success, error in
                if let error = error {
                    showSignInError(error)
                } else {
                    isAuthenticating = true

                    _Concurrency.Task {
                        do {
                            let timestamp = Date()
                            let dateString = DateFormatter.iso8601Full.string(from: timestamp)
                            let preauthenticatedKey = try deviceKey.preauthenticatedKey(context: context)
                            let signature = try preauthenticatedKey.signature(for: dateString.data(using: .utf8)!).base64EncodedString()

                            let token: CensoAuthProvider.JWTToken = try await censoApi.provider.request(.login(.signature(email: username, timestamp: timestamp, signature: signature, publicKey: try deviceKey.publicExternalRepresentation().base58String)))

                            if let encryptedRootSeed = try Keychain.encryptedRootSeed(email: username),
                               let rootSeed = try? preauthenticatedKey.decrypt(data: encryptedRootSeed),
                               let publicKeys = try? PrivateKeys(rootSeed: rootSeed.bytes).publicKeys {
                                // registered and authenticated
                                let registeredDevice = RegisteredDevice(email: username, deviceKey: deviceKey, encryptedRootSeed: encryptedRootSeed, publicKeys: publicKeys)

                                await MainActor.run {
                                    authProvider.authenticatedState = .deviceAuthenticatedRegistered(registeredDevice, token: token)
                                }
                            } else {
                                // authenticated but not yet registered

                                await MainActor.run {
                                    authProvider.authenticatedState = .deviceAuthenticatedUnregistered(deviceKey, token: token)
                                }
                            }
                        } catch {

                            await MainActor.run {
                                showSignInError(error)
                            }
                        }

                        isAuthenticating = false
                    }
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
