//
//  MFARequiredView.swift
//  Strike
//
//  Created by Donald Ness on 4/5/21.
//

import SwiftUI
import OktaAuthNative

struct MFARequiredView: View {
    @Environment(\.presentationMode) var presentation
    
    let status: OktaAuthStatusFactorRequired
    let onReceiveSessionToken: (String) -> Void
    
    @State private var nextStatus: OktaAuthStatus?
    @State private var isLoading: Bool = false
    
    enum AlertType {
        case selectFactorError(Error)
    }
    
    @State private var currentAlert: AlertType?
    
    var body: some View {
        VStack {
            switch nextStatus {
            case .none:
                if let totpFactor = totpFactor {
                    ProgressView().onAppear {
                        verify(totpFactor: totpFactor)
                    }
                    .alert(item: $currentAlert) { item in
                        switch item {
                        case .selectFactorError:
                            return Alert.withDismissButton(title: Text("Verification Error"), message: Text("Unable to verify"))
                        }
                    }
                } else {
                    UnsupportedAuthStatusView(status: status)
                }
            case let factorChallengeStatus as OktaAuthStatusFactorChallenge:
                MFAChallengeView(status: factorChallengeStatus, onReceiveSessionToken: onReceiveSessionToken)
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
    
    private var totpFactor: OktaFactorTotp? {
        return status
            .availableFactors.compactMap { $0 as? OktaFactorTotp }
            .first
    }
    
    private func verify(totpFactor: OktaFactorTotp) {
        isLoading = true
        status.selectFactor(
            totpFactor,
            onStatusChange: { status in
                isLoading = false
                nextStatus = status
            },
            onError: { error in
                isLoading = false
                currentAlert = .selectFactorError(error)
            })
    }
    
    private func close() {
        presentation.wrappedValue.dismiss()
    }
}

extension MFARequiredView.AlertType: Identifiable {
    var id: Int {
        switch self {
        case .selectFactorError:
            return 0
        }
    }
}
