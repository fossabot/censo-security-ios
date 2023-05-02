//
//  EnableOrDisableDeviceDetails.swift
//  Censo
//
//  Created by Brendan Flood on 2/28/23.
//

import Foundation
import SwiftUI

struct EnableOrDisableDeviceDetails: View {
    var request: ApprovalRequest
    var userDevice: UserDevice

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            FactList {
                Fact("Name", userDevice.name)
                Fact("Email", userDevice.email)
                Fact("Device Type", userDevice.deviceType.description)
            }
            if let data = Data(base64Encoded: userDevice.jpegThumbnail), let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage).clipShape(Circle())
            }
        }
    }
}

#if DEBUG
struct EnableDeviceDetails_Previews: PreviewProvider {
    static var previews: some View {
        EnableOrDisableDeviceDetails(request: .sample, userDevice: EnableDevice.sample)
    }
}
#endif
