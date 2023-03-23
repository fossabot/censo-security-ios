//
//  VaultUserRolesUpdateRow.swift
//  Censo
//
//  Created by Anton Onyshchenko on 23.03.23.
//

import Foundation
import SwiftUI

struct VaultUserRolesUpdateRow: View {
    var requestType: ApprovalRequestType
    var update: VaultUserRolesUpdate

    var body: some View {
        VStack(spacing: 8) {
            Text(requestType.header)
                .font(.title2.bold())
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .padding(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20))

            Text(update.vaultName.toVaultName())
                .font(.title3)
                .foregroundColor(Color.Censo.primaryForeground.opacity(0.7))
                .padding(EdgeInsets(top: 2, leading: 20, bottom: 20, trailing: 20))
        }
    }
}

#if DEBUG
struct VaultUserRolesUpdateRow_Previews: PreviewProvider {
    static var previews: some View {
        VaultUserRolesUpdateRow(requestType: .vaultUserRolesUpdate(.sample),
                                update: .sample)
        .preferredColorScheme(.light)
    }
}

extension VaultUserRolesUpdate {
    static var sample: Self {
        VaultUserRolesUpdate(
            vaultName: "XYZ Vault",
            userRoles: [
                VaultUserRole(
                    name: "User 1",
                    email: "user1@org.com",
                    jpegThumbnail: nil,
                    role: VaultUserRoleEnum.TransactionSubmitter
                )
            ]
        )
    }
}


#endif
