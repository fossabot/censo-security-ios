//
//  WalletConfigPolicyRow.swift
//  Censo
//
//  Created by Ata Namvari on 2022-05-03.
//

import Foundation
import SwiftUI


struct VaultConfigPolicyRow: View {
    var requestType: ApprovalRequestType
    var update: VaultPolicyUpdate

    var body: some View {
        VStack(spacing: 8) {
            Text(requestType.header)
                .font(.title2)
                .bold()
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))
            
            if let header2 = requestType.header {
                Text(header2)
                    .font(.title3)
                    .foregroundColor(Color.Censo.primaryForeground.opacity(0.7))
                    .padding(EdgeInsets(top: 2, leading: 20, bottom: 20, trailing: 20))
            }
        }
    }
}

extension Int {
    var approversCaption: String {
        if self == 1 {
            return "\(self) approver"
        } else {
            return "\(self) approvers"
        }
    }
}

#if DEBUG
struct VaultConfigPolicyRow_Previews: PreviewProvider {
    static var previews: some View {
        VaultConfigPolicyRow(requestType: .vaultPolicyUpdate(.sample), update: .sample)
            .preferredColorScheme(.light)
    }
}

extension VaultPolicyUpdate {
    static var sample: Self {
        VaultPolicyUpdate(
            approvalPolicy: .sample,
            currentOnChainPolicies: [.sample],
            vaultName: "XYZ Vault",
            signingData: [SigningData.ethereum(signingData: .sample)],
            chainFees: [.sample, .sample2]
        )
    }
}

extension VaultApprovalPolicy {
    static var sample: Self {
        VaultApprovalPolicy(
            approvalsRequired: 2,
            approvalTimeout: 3000,
            approvers: [VaultSigner.sample]
        )
    }
}

extension VaultSigner {
    static var sample: Self {
        VaultSigner(name: "John Smith",
                    email: "john@censocustody.com",
                    publicKeys: [],
                    nameHashIsEmpty: false,
                    jpegThumbnail: nil
        )
    }
}

extension ChainFee {
    static var sample: Self {
        ChainFee(chain: Chain.ethereum,
                 fee: .feeSample,
                 feeSymbolInfo: .sample)
    }
    static var sample2: Self {
        ChainFee(chain: Chain.polygon,
                 fee: .feeSample,
                 feeSymbolInfo: .sample)
    }
}

#endif
