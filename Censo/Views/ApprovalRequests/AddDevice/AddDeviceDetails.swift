//
//  AddDeviceDetails.swift
//  Censo
//
//  Created by Brendan Flood on 2/28/23.
//

import Foundation
import SwiftUI

struct AddDeviceDetails: View {
    var request: ApprovalRequest
    var addDevice: AddDevice

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            FactList {
                Fact("Name", addDevice.name)
                Fact("Email", addDevice.email)
                Fact("Device Type", addDevice.deviceType.description)
            }
            if let data = Data(base64Encoded: addDevice.jpegThumbnail), let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
            }
        }
    }
}

#if DEBUG
struct AddDeviceDetails_Previews: PreviewProvider {
    static var previews: some View {
        AddDeviceDetails(request: .sample, addDevice: .sample)
    }
}
#endif
