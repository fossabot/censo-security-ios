//
//  RestoreUserDetails.swift
//  Censo
//
//  Created by Anton Onyshchenko on 28.03.23.
//

import Foundation
import SwiftUI

struct RestoreUserDetails: View {
    var request: ApprovalRequest
    var restoreUser: RestoreUser

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            FactList {
                Fact("Name", restoreUser.name)
                Fact("Email", restoreUser.email)
            }
        }
    }
}

#if DEBUG
struct RestoreUserDetails_Previews: PreviewProvider {
    static var previews: some View {
        RestoreUserDetails(request: .sample, restoreUser: .sample)
    }
}
#endif
