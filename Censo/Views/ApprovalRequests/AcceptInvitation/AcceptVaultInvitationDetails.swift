//
//  AcceptVaultInvitationDetails.swift
//  Censo
//
//  Created by Brendan Flood on 6/21/22.
//


import SwiftUI

struct AcceptVaultInvitationDetails: View {
    var requestType: ApprovalRequestType
    var acceptVaultInvitation: AcceptVaultInvitation

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
        }
    }
}

#if DEBUG
struct AcceptVaultInvitationDetails_Previews: PreviewProvider {
    static var previews: some View {
        AcceptVaultInvitationDetails(requestType: .vaultInvitation(.sample), acceptVaultInvitation: .sample)

        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        NavigationView {
            ApprovalRequestDetails(deviceSigner: DeviceSigner(deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, request: .sample, timerPublisher: timerPublisher) {
                AcceptVaultInvitationDetails(requestType: .vaultInvitation(.sample), acceptVaultInvitation: .sample)
            }
        }
    }
}
#endif
