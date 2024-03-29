//
//  KeyGeneration.swift
//  Censo
//
//  Created by Ata Namvari on 2022-03-02.
//

import Foundation
import SwiftUI
import BIP39

struct KeyGeneration: View {
    @State private var phrase = Mnemonic(strength: 256).phrase

    var user: CensoApi.User
    var shardingPolicy: ShardingPolicy
    var deviceKey: DeviceKey
    var registrationController: DeviceRegistrationController
    var onConflict: () -> Void
    var onSuccess: () -> Void

    var body: some View {
        KeyConfirmationSuccess(user: user, deviceKey: deviceKey, registrationController: registrationController, phrase: phrase, shardingPolicy: shardingPolicy, onConflict: onConflict, onSuccess: onSuccess)
    }
}

#if DEBUG
//struct KeyGeneration_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            KeyGeneration(user: .sample, shardingPolicy: .sample, deviceKey: .sample, onConflict: {}, onSuccess: {})
//        }
//    }
//}
#endif
