//
//  BalanceAccountNameRow.swift
//  Censo
//
//  Created by Ata Namvari on 2022-05-03.
//

import Foundation
import SwiftUI


struct NameUpdateRow: View {
    var requestType: ApprovalRequestType
    var update: NameUpdate

    var body: some View {
        VStack(spacing: 8) {
            Text(requestType.header)
                .font(.title2)
                .bold()
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))
            
            if let header2 = requestType.header2 {
                Text(header2)
                    .font(.title3)
                    .lineLimit(1)
                    .allowsTightening(true)
                    .foregroundColor(Color.Censo.primaryForeground.opacity(0.7))
                    .padding(EdgeInsets(top: 2, leading: 20, bottom: 20, trailing: 20))
            }
        }
    }
}

#if DEBUG
struct NameUpdateRow_Previews: PreviewProvider {
    static var previews: some View {
        NameUpdateRow(requestType: .vaultNameUpdate(.sample), update: VaultNameUpdate.sample)
            .preferredColorScheme(.light)
    }
}

extension VaultNameUpdate {
    static var sample: Self {
        VaultNameUpdate(
            oldName: "Old",
            newName: "New Vault",
            signingData: [SigningData.ethereum(signingData: .sample)],
            chainFees: [.sample, .sample2]
        )
    }
}
#endif
