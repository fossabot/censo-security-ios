//
//  SuspendUserDetails.swift
//  Censo
//
//  Created by Anton Onyshchenko on 28.03.23.
//

import Foundation
import SwiftUI

struct SuspendUserDetails: View {
    var request: ApprovalRequest
    var suspendUser: SuspendUser

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            FactList {
                Fact("Name", suspendUser.name)
                Fact("Email", suspendUser.email)
            }
        }
    }
}

#if DEBUG
struct SuspendUserDetails_Previews: PreviewProvider {
    static var previews: some View {
        SuspendUserDetails(request: .sample, suspendUser: .sample)
    }
}
#endif
