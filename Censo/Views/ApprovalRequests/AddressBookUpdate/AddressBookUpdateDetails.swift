//
//  AddressBookUpdateDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2022-05-03.
//

import Foundation
import SwiftUI

struct AddressBookUpdateDetails: View {
    var request: ApprovalRequest
    var update: AddressBookUpdate

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            FactList {
                Fact("Name", update.entry.name)
                Fact("Address", update.entry.address.masked())
                Fact("Chain", update.entry.chain.rawValue.capitalized)
            }
        }
    }
}


#if DEBUG
struct AddressBookUpdateDetails_Previews: PreviewProvider {
    static var previews: some View {
        AddressBookUpdateDetails(request: .sample, update: .sample)

        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        NavigationView {
            ApprovalRequestDetails(deviceSigner: DeviceSigner(deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, request: .sample, timerPublisher: timerPublisher) {
                AddressBookUpdateDetails(request: .sample, update: .sample)
            }
        }
    }
}
#endif
