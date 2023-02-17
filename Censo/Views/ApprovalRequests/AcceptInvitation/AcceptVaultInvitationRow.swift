//
//  AcceptVaultInvitationRow.swift
//  Censo
//
//  Created by Brendan Flood on 6/21/22.
//

import SwiftUI

struct AcceptVaultInvitationRow: View {
    var requestType: ApprovalRequestType
    var acceptVaultInvitation: AcceptVaultInvitation

    var body: some View {
        VStack(spacing: 8) {
            Text(requestType.header)
                .font(.title2.bold())
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .padding(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20))

            Text(acceptVaultInvitation.vaultName.toVaultName())
                .font(.title3)
                .foregroundColor(Color.Censo.primaryForeground.opacity(0.7))
                .padding(EdgeInsets(top: 2, leading: 20, bottom: 20, trailing: 20))
        }
    }
}

#if DEBUG
struct AcceptVaultInvitation_Previews: PreviewProvider {
    static var previews: some View {
        AcceptVaultInvitationRow(requestType: .vaultInvitation(.sample), acceptVaultInvitation: .sample)
            .preferredColorScheme(.light)
    }
}

extension AcceptVaultInvitation {
    static var sample: Self {
        AcceptVaultInvitation(vaultGuid: "vaultGuid", vaultName: "Vault Name")
    }
}

#endif

