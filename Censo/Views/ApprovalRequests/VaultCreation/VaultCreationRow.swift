//
//  VaultCreationRow.swift
//  Censo
//
//  Created by Brendan Flood on 2/28/23.
//

import Foundation
import SwiftUI

struct VaultCreationRow: View {
    var requestType: ApprovalRequestType
    var vaultCreation: VaultCreation

    var body: some View {
        VStack(spacing: 8) {
            Text(requestType.header)
                .font(.title2.bold())
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .padding(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20))

            Text(vaultCreation.name.toVaultName())
                .font(.title3)
                .foregroundColor(Color.Censo.primaryForeground.opacity(0.7))
                .padding(EdgeInsets(top: 2, leading: 20, bottom: 20, trailing: 20))
        }
    }
}

#if DEBUG
struct VaultCreationRow_Previews: PreviewProvider {
    static var previews: some View {
        VaultCreationRow(requestType: .vaultCreation(.sample),
                         vaultCreation: .sample)
        .preferredColorScheme(.light)
    }
}

extension VaultCreation {
    static var sample: Self {
        VaultCreation(
            approvalPolicy: .sample,
            name: "XYZ Vault",
            signingData: [],
            chainFees: [.sample, .sample2]
        )
    }
}


#endif
