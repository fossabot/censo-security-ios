//
//  SuspendUserDetails.swift
//  Censo
//
//  Created by Anton Onyshchenko on 28.03.23.
//

import Foundation
import SwiftUI

struct UserDetails: View {
    var request: ApprovalRequest
    var user: UserInfo

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            FactList {
                Fact("Name", user.name)
                Fact("Email", user.email)
            }
            if user.jpegThumbnail != nil, let data = Data(base64Encoded: user.jpegThumbnail!), let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
            }
        }
    }
}

#if DEBUG
struct UserDetails_Previews: PreviewProvider {
    static var previews: some View {
        UserDetails(request: .sample, user: SuspendUser.sample as UserInfo)
    }
}
#endif
