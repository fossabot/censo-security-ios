//
//  SignInView.swift
//  Censo
//
//  Created by Donald Ness on 3/25/21.
//

import SwiftUI
import Moya
import LocalAuthentication
import CryptoKit

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
            case .signInError(let error as MoyaError):
                return Alert(
                    title: Text("Sign In Error"),
                    message: Text(error.message),
                    dismissButton: .cancel(Text("OK"))
                )
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
            deviceKey.preauthenticatedKey { result in
                switch result {
                case .success(let preauthenticatedKey):
                    isAuthenticating = true

                    _Concurrency.Task {
                        do {
                            let timestamp = Date()
                            let dateString = DateFormatter.iso8601Full.string(from: timestamp)
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
                            print(error)
                            await MainActor.run {
                                showSignInError(error)
                            }
                        }

                        isAuthenticating = false
                    }
                case .failure(let error):
                    showSignInError(error)
                }
            }
        } else {
            isAuthenticating = true

            censoApi.provider.request(.emailVerification(username)) { result in
                isAuthenticating = false

                switch result {
                case .failure(let error):
                    showSignInError(error)
                case .success(let response) where response.statusCode < 400:
                    showingVerification = true
                case .success(let response):
                    showSignInError(MoyaError.statusCode(response))
                }
            }
        }
    }

    private func showSignInError(_ error: Error) {
        currentAlert = .signInError(error)
    }
}

import CryptoTokenKit

extension DeviceKey {
    enum DeviceKeyError: Error {
        case keyInvalidatedByBiometryChange
    }

    func preauthenticatedKey(_ completion: @escaping (Result<PreauthenticatedKey<DeviceKey>, Error>) -> Void) {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Identify Yourself") { success, error in
            if let error = error {
                // not authenticated
                completion(.failure(error))
            } else {
                do {
                    let preauthenticatedKey = try self.preauthenticatedKey(context: context)
                    let sampleData = Data(repeating: 1, count: 8)
                    _ = try preauthenticatedKey.signature(for: sampleData)

                    completion(.success(preauthenticatedKey))
                } catch (let error as NSError) where error._domain == "CryptoTokenKit" && error._code == -3 {
                    // key no longer valid
                    do {
                        try SecureEnclaveWrapper.removeDeviceKey(self)
                        completion(.failure(DeviceKeyError.keyInvalidatedByBiometryChange))
                    } catch {
                        completion(.failure(error))
                    }
                } catch {
                    // other error
                    print(error)
                    completion(.failure(error))
                }
            }
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
