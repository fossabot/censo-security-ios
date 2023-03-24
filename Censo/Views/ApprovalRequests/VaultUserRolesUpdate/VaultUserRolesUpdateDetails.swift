//
//  VaultUserRolesUpdateDetails.swift
//  Censo
//
//  Created by Anton Onyshchenko on 23.03.23.
//


import Foundation
import SwiftUI

struct VaultUserRolesUpdateDetails: View {
    var request: ApprovalRequest
    var update: VaultUserRolesUpdate

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            FactList {
                Fact("Vault Name", update.vaultName)
            }

            FactsSection(title: "User Roles") {
                for userRole in update.userRoles {
                    Fact(userRole.name, userRole.role.description)
                }
            }
        }
    }
}

#if DEBUG
struct VaultUserRolesUpdateDetails_Previews: PreviewProvider {
    static var previews: some View {
        VaultUserRolesUpdateDetails(request: .sample, update: .sample)
    }
}
#endif
