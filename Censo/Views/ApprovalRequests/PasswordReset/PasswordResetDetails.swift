//
//  PasswordResetDetails.swift
//  Censo
//
//  Created by Brendan Flood on 8/10/22.
//

import Foundation

import SwiftUI

struct PasswordResetDetails: View {
    var requestType: ApprovalRequestType

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
        }
    }
}

#if DEBUG
//struct PasswordResetDetails_Previews: PreviewProvider {
//    static var previews: some View {
//        PasswordResetDetails(requestType: .passwordReset(.sample))
//
//        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()
//
//        NavigationView {
//            ApprovalRequestDetails(registeredDevice: RegisteredDevice(email: "test@test.com", deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, request: .sample, timerPublisher: timerPublisher) {
//                PasswordResetDetails(requestType: .passwordReset(.sample))
//            }
//        }
//    }
//}
#endif
