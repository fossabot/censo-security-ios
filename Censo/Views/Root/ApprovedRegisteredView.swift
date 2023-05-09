//
//  ApprovedRegisteredView.swift
//  Censo
//
//  Created by Ata Namvari on 2023-05-09.
//

import SwiftUI

struct ApprovedRegisteredView: View {
    @Environment(\.censoApi) var censoApi

    var user: CensoApi.User
    var registeredDevice: RegisteredDevice
    var shardingPolicy: ShardingPolicy
    var reloadUser: () -> Void

    var body: some View {
        switch user.registeredPublicKeys {
        case .incomplete:
            AdditionalKeyRegistration(user: user, registeredDevice: registeredDevice, shardingPolicy: shardingPolicy) {
                reloadUser()
            }
        case .complete(let remotePublicKeys) where registeredDevice.publicKeys == remotePublicKeys:
            ApprovalRequestsView(
                registeredDevice: registeredDevice,
                user: user
            )
            .navigationTitle("Approvals")
        case .complete:
            Text("Keys do not match, call support")
        case .none:
            Text("Should not have come here")
        }
    }
}
