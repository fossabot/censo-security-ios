//
//  RecoverPasswordChallengeView.swift
//  Strike
//
//  Created by Donald Ness on 3/29/21.
//

import SwiftUI
import OktaAuthNative

struct RecoverPasswordChallengeView: View {
    let status: OktaAuthStatusRecoveryChallenge
    
    @State private var isResending: Bool = false
    
    var body: some View {
        if canVerify {
            // Verification with passcode is not currently supported.
            // If this is turned on in the Okta configuration for some reason,
            // then this becomes a dead end. Open Safari here instead?
            UnsupportedAuthStatusView(status: status)
        } else {
            VStack {
                Spacer()
                
                Text("Check your inbox for instructions on how to reset your password.")
                    .padding()
                
                Spacer()
                
                if canResend {
                    Button("Resend Verification Email", action: resend)
                        .foregroundColor(Color.Strike.purple)
                        .disabled(isResending)
                        .padding()
                }
            }
        }
    }
    
    private var canVerify: Bool {
        return status.canVerify()
    }
    
    private var canResend: Bool {
        return status.canResend()
    }
    
    private func resend() {
        isResending = true
        status.resendFactor(
            onStatusChange: { status in
                isResending = false
            },
            onError: { error in
                isResending = false
            })
    }
}
