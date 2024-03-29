//
//  ApprovalRequestDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2021-04-19.
//

import Foundation
import SwiftUI
import CryptoKit
import Combine
import raygun4apple
import LocalAuthentication

struct ApprovalRequestDetails<Content>: View where Content : View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.censoApi) var censoApi

    @State private var action: Action = .none
    @State private var alert: AlertType? = nil
    @State private var isComposingMail = false
    @State private var timeRemaining: DateComponents = DateComponents()

    var registeredDevice: RegisteredDevice
    var user: CensoApi.User
    var request: ApprovalRequest
    var timerPublisher: Publishers.Autoconnect<Timer.TimerPublisher>
    var onApprove: (() -> Void)?
    var onDecline: (() -> Void)?
    @ViewBuilder var content: () -> Content

    var statusTitle: String = "STATUS"

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                VStack(alignment: .center, spacing: 15) {
                    VStack(alignment: .center, spacing: 0) {
                        Text(request.details.header)
                            .font(.title)
                            .bold()
                            .lineLimit(1)
                            .allowsTightening(true)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.25)
                            .padding(.top, 20)

                        if let header2 = request.details.header2 {
                            Text(header2)
                                .font(.title2)
                                .lineLimit(1)
                                .allowsTightening(true)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.25)
                                .foregroundColor(Color.Censo.primaryForeground.opacity(0.7))
                                .padding(.top, 5)
                        }
                        
                        if let subHeader = request.details.subHeader {
                            Text(subHeader)
                                .font(.caption)
                                .foregroundColor(Color.Censo.primaryForeground.opacity(0.5))
                                .padding(.top, 5)
                        }
                    }
                    .padding(.bottom, 10)

                    content()

                    FactsSection(title: statusTitle) {
                        if let vaultName = request.vaultName {
                            Fact("Vault Name", vaultName)
                        }
                        Fact("Initiated By", request.submitterEmail) {
                            isComposingMail = true
                        }
                        Fact("Approvals Received", "\(request.numberOfApprovalsReceived) of \(request.numberOfDispositionsRequired)")

                        Fact("Denials Received", "\(request.numberOfDeniesReceived) of \(request.numberOfDispositionsRequired)")
                        
                        
                        if let expireDate = request.expireDate {
                            if expireDate <= Date() {
                                Fact("Expired", "")
                            } else {
                                Fact("Expires In", formattedCountdown)
                            }
                        }
                    }
                    .onReceive(timerPublisher) { _ in
                        updateTimeRemaining()
                    }
                    .onAppear(perform: updateTimeRemaining)
                }
            }

            VStack(alignment: .center, spacing: 15) {
                Button {
                    switch request.details {
                    case .loginApproval:
                        ignore()
                    default:
                        alert = .ignoreConfirmation
                    }
                } label: {
                    Text(request.ignoreCaption.capitalized)
                        .loadingIndicator(when: action == .ignoring)
                }
                .buttonStyle(DestructiveButtonStyle())

                Button {
                    switch request.details {
                    case .loginApproval:
                        approve()
                    default:
                        alert = .approveConfirmation
                    }
                } label: {
                    Text(request.approveButtonCaption)
                        .loadingIndicator(when: action == .approving)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .background(
                Rectangle()
                    .ignoresSafeArea()
                    .foregroundColor(.Censo.primaryBackground)
                    .shadow(color: .Censo.lightGray, radius: 2, x: 0, y: -1)
            )
        }
        .background(Color.Censo.primaryBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .disabled(action != .none)
        .alert(item: $alert) { alertType in
            switch alertType {
            case .approveConfirmation:
                return Alert(
                    title: Text("Are you sure?"),
                    message: Text("You are about to approve the following request:\n \(request.details.header)"),
                    primaryButton: Alert.Button.default(Text("Confirm"), action: approve),
                    secondaryButton: Alert.Button.cancel(Text("Cancel"))
                )
            case .ignoreConfirmation:
                return Alert(
                    title: Text("Are you sure?"),
                    message: Text("You are about to \(request.ignoreCaption) the following request:\n \(request.details.header)"),
                    primaryButton: Alert.Button.default(Text("Confirm"), action: ignore),
                    secondaryButton: Alert.Button.cancel(Text("Cancel"))
                )
            case .ignoreError(let error):
                return Alert.withDismissButton(title: Text("Error"), message: Text(error.message))
            case .approveError(let error):
                return Alert.withDismissButton(title: Text("Error"), message: Text(error.message))
            }
        }
        .navigationBarItems(
            leading: Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                    .foregroundColor(.Censo.primaryForeground)
                    .font(.body.bold())
            }
        )
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Details")
        .sheet(isPresented: $isComposingMail) {
            ComposeMail(
                subject: "Censo Approval Request: \(request.id) on \(request.submitDate)",
                toRecipients: [request.submitterEmail],
                completion: nil
            )
        }
        .foregroundColor(.Censo.primaryForeground)
    }

    private func updateTimeRemaining() {
        if let expireDate = request.expireDate {
            timeRemaining = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: expireDate)
        }
    }

    private var formattedCountdown: String {
        DateComponentsFormatter.positionalFormatter.string(for: timeRemaining) ?? ""
    }

    private func approve() {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Verify your identity") { success, error in
            if let error = error {
                alert = .approveError(error)
            } else {
                action = .approving

                Task {
                    defer {
                        action = .none
                    }

                    do {
                        let preauthenticatedDeviceKey = try registeredDevice.deviceKey.preauthenticatedKey(context: context)
                        let preauthenticatedBootstrapKey = try registeredDevice.deviceKey.bootstrapKey()?.preauthenticatedKey(context: context)
                        let request = ApprovalDispositionRequest(disposition: .Approve, request: request)
                        let payload = try await CensoApi.ApprovalDispositionPayload(
                            dispositionRequest: request,
                            deviceKey: preauthenticatedDeviceKey,
                            bootstrapKey: preauthenticatedBootstrapKey,
                            encryptedRootSeed: registeredDevice.encryptedRootSeed,
                            apiProvider: censoApi.provider
                        )

                        _ = try await censoApi.provider.request(
                            .registerApprovalDisposition(
                                payload,
                                devicePublicKey: try registeredDevice.devicePublicKey()
                            )
                        )

                        await MainActor.run {
                            onApprove?()
                            dismiss()
                        }
                    } catch {
                        RaygunClient.sharedInstance().send(error: error, tags: ["approval-error"], customData: nil)

                        await MainActor.run {
                            print(error)
                            alert = .approveError(error)
                        }
                    }
                }
            }
        }
    }

    private func ignore() {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Verify your identity") { success, error in
            if let error = error {
                alert = .approveError(error)
            } else {
                action = .ignoring

                Task {
                    defer {
                        action = .none
                    }

                    do {
                        let preauthenticatedDeviceKey = try registeredDevice.deviceKey.preauthenticatedKey(context: context)
                        let preauthenticatedBootstrapKey = try registeredDevice.deviceKey.bootstrapKey()?.preauthenticatedKey(context: context)
                        let request = ApprovalDispositionRequest(disposition: .Deny, request: request)

                        _ = try await censoApi.provider.request(
                            .registerApprovalDisposition(
                                CensoApi.ApprovalDispositionPayload(
                                    dispositionRequest: request,
                                    deviceKey: preauthenticatedDeviceKey,
                                    bootstrapKey: preauthenticatedBootstrapKey,
                                    encryptedRootSeed: registeredDevice.encryptedRootSeed,
                                    apiProvider: censoApi.provider
                                ),
                                devicePublicKey: try registeredDevice.devicePublicKey()
                            )
                        )

                        await MainActor.run {
                            onDecline?()
                            dismiss()
                        }
                    } catch {
                        RaygunClient.sharedInstance().send(error: error, tags: ["approval-error"], customData: nil)

                        await MainActor.run {
                            print(error)
                            alert = .ignoreError(error)
                        }
                    }
                }
            }
        }
    }
}

extension ApprovalRequestDetails {
    enum Action: Int, Equatable {
        case none
        case approving
        case ignoring
    }
}

extension ApprovalRequestDetails {
    enum AlertType: Identifiable {
        case approveConfirmation
        case ignoreConfirmation
        case ignoreError(Error)
        case approveError(Error)

        var id: String {
            switch self {
            case .approveConfirmation:
                return "approve"
            case .ignoreConfirmation:
                return "deny"
            case .ignoreError(let error),
                 .approveError(let error):
                return error.localizedDescription
            }
        }
    }
}

extension ApprovalRequest {
    var ignoreCaption: String {
        return "deny"
    }
}


#if DEBUG
//struct ApprovalRequestDetails_Previews: PreviewProvider {
//    static var previews: some View {
//        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()
//
//        NavigationView {
//            ApprovalRequestDetails(registeredDevice: RegisteredDevice(email: "test@test.com", deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, request: .sample, timerPublisher: timerPublisher) {
//                WithdrawalDetails(request: .sample, withdrawal: EthereumWithdrawalRequest.sample)
//            }
//        }
//        .preferredColorScheme(.light)
//    }
//}
#endif
