//
//  ApprovalRequestRow.swift
//  Censo
//
//  Created by Ata Namvari on 2021-04-19.
//

import Foundation
import SwiftUI
import CryptoKit
import Combine

struct ApprovalRequestRow<Row, Detail>: View where Row : View, Detail: View {
    @Environment(\.censoApi) var censoApi

    @State private var isLoading = false
    @State private var alert: AlertType? = nil
    @State private var navigated = false

    var deviceSigner: DeviceSigner
    var user: CensoApi.User
    var request: ApprovalRequest
    var timerPublisher: Publishers.Autoconnect<Timer.TimerPublisher>
    var onStatusChange: (() -> Void)?
    @ViewBuilder var row: () -> Row
    @ViewBuilder var detail: () -> Detail
    
    var titleVaultName: String? {
        return request.vaultName?.toVaultName()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                if let titleVaultName = titleVaultName {
                    Text(titleVaultName)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .allowsTightening(true)
                        .font(.subheadline)
                }
                Spacer()
                if let expireDate = request.expireDate {
                    Countdown(date: expireDate, timerPublisher: timerPublisher)
                        .font(.subheadline)
                        .foregroundColor(Color.Censo.primaryForeground.opacity(0.7))
                }
            }
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .background(Color.white)

            row()

            Divider()

            HStack(spacing: 0) {
                Button {
                    switch request.details {
                    case .loginApproval:
                        approve()
                    default:
                        alert = .confirmation
                    }
                } label: {
                    Text(request.approveButtonCaption)
                        .bold()
                        .loadingIndicator(when: isLoading)
                        .foregroundColor(Color.Censo.green)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.Censo.green))
                }
                .alert(item: $alert) { alertType in
                    switch alertType {
                    case .confirmation:
                        return Alert(
                            title: Text("Are you sure?"),
                            message: Text("You are about to approve the following request:\n \(request.details.header)"),
                            primaryButton: Alert.Button.default(Text("Confirm"), action: approve),
                            secondaryButton: Alert.Button.cancel(Text("Cancel"))
                        )
                    case .error(let error):
                        return Alert.withDismissButton(title: Text("Error"), message: Text(error.message))
                    }
                }

                Divider()

                Button {
                    navigated = true
                } label: {
                    Text("More Info...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(height: 45)
            .disabled(isLoading)

            NavigationLink(isActive: $navigated) {
                ApprovalRequestDetails(
                    deviceSigner: deviceSigner,
                    user: user,
                    request: request,
                    timerPublisher: timerPublisher,
                    onStatusChange: onStatusChange,
                    content: detail
                )
                .environment(\.censoApi, censoApi)
            } label: {
                EmptyView()
            }
            .hidden()
        }
        .roundedCell(background: Color.white)
        .foregroundColor(.Censo.primaryForeground)
    }

    private func approve() {
        isLoading = true

        Task {
            defer {
                isLoading = false
            }

            do {
                let request = ApprovalDispositionRequest(disposition: .Approve, request: request)

                _ = try await censoApi.provider.request(
                    .registerApprovalDisposition(
                        CensoApi.ApprovalDispositionPayload(
                            dispositionRequest: request,
                            deviceSigner: deviceSigner,
                            apiProvider: censoApi.provider
                        ),
                        devicePublicKey: try deviceSigner.devicePublicKey()
                    )
                )

                await MainActor.run {
                    onStatusChange?()
                }
            } catch {
                await MainActor.run {
                    print(error)
                    alert = .error(error)
                }
            }
        }
    }
}

extension ApprovalRequestRow {
    enum AlertType: Identifiable {
        case confirmation
        case error(Error)

        var id: String {
            switch self {
            case .confirmation:
                return "confirmation"
            case .error(let error):
                return error.localizedDescription
            }
        }
    }
}

extension ApprovalRequest {
    var expireDate: Date? {
        approvalTimeoutInSeconds != nil ? submitDate.addingTimeInterval(TimeInterval(approvalTimeoutInSeconds!)) : nil
    }
}

extension ApprovalRequest {
    var approveButtonCaption: String {
        if self.initiationOnly {
            return "Initiate"
        } else {
            return "Approve"
        }
    }
}

#if DEBUG
struct ApprovalRequestRow_Previews: PreviewProvider {
    static var previews: some View {
        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        ApprovalRequestRow(deviceSigner: .init(deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, request: .sample, timerPublisher: timerPublisher) {
            WithdrawalRow(requestType: .ethereumWithdrawalRequest(.sample), withdrawal: EthereumWithdrawalRequest.sample)
        } detail: {
            WithdrawalDetails(request: .sample, withdrawal: EthereumWithdrawalRequest.sample)
        }
    }
}

extension EthereumWithdrawalRequest {
    static var sample: Self {
        EthereumWithdrawalRequest(
            wallet: .sample,
            amount: .sample,
            symbolInfo: .sample,
            fee: .feeSample,
            feeSymbolInfo: EvmSymbolInfo.sample,
            destination: .sample,
            signingData: .sample)
    }
}
#endif
