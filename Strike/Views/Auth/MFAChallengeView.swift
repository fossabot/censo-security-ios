//
//  MFAChallengeView.swift
//  Strike
//
//  Created by Donald Ness on 4/5/21.
//

import SwiftUI
import OktaAuthNative

struct MFAChallengeView: View {
    @Environment(\.presentationMode) var presentation
    
    let status: OktaAuthStatusFactorChallenge
    let onReceiveSessionToken: (String) -> Void
    
    @State private var code: String = ""
    @State private var nextStatus: OktaAuthStatus?
    @State private var isLoading: Bool = false
    
    enum AlertType {
        case verifyFactorError(Error)
    }
    
    @State private var currentAlert: AlertType?
    
    var body: some View {
        VStack {
            switch nextStatus {
            case .none:
                VStack {
                    Spacer()
                    
                    Text("Enter the 6-digit code in Google Authenticator.")
                        .padding()
                    
                    TextField("Code", text: $code)
                        .keyboardType(.numberPad)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(Color.white)
                        .accentColor(Color.Strike.purple)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isLoading)
                        .padding()
                    
                    Spacer()
                    
                    Button(action: verify) {
                        Text("Verify")
                            .loadingIndicator(when: isLoading)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(FilledButtonStyle())
                    .disabled(code.isEmpty || isLoading)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .padding()
                }
                .alert(item: $currentAlert) { item in
                    switch item {
                    case .verifyFactorError:
                        return Alert.withDismissButton(title: Text("Verification Error"), message: Text("Please check your verification code"))
                    }
                }
            case .some(let unsupportedStatus):
                UnsupportedAuthStatusView(status: unsupportedStatus)
            }
        }
        .background(
            Color.Strike.secondaryBackground
                .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Verification")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: close) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var canVerify: Bool {
        return status.canVerify()
    }
    
    private func verify() {
        isLoading = true
        status.verifyFactor(
            passCode: code,
            answerToSecurityQuestion: nil,
            onStatusChange: { status in
                guard let successStatus = status as? OktaAuthStatusSuccess, let sessionToken = successStatus.sessionToken else {
                    isLoading = false
                    nextStatus = status
                    return
                }

                close()
                onReceiveSessionToken(sessionToken)
            },
            onError: { error in
                isLoading = false
                currentAlert = .verifyFactorError(error)
            })
    }
    
    private func close() {
        presentation.wrappedValue.dismiss()
    }
}

extension MFAChallengeView.AlertType: Identifiable {
    var id: Int {
        switch self {
        case .verifyFactorError:
            return 0
        }
    }
}
