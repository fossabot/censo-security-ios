//
//  Networking+Environment.swift
//  Censo
//
//  Created by Ata Namvari on 2021-03-11.
//

import Foundation
import SwiftUI
import Moya

// CensoApi

struct CensoApiProviderEnvironmentKey: EnvironmentKey {
    static var defaultValue = CensoApi()
}

extension EnvironmentValues {
    var censoApi: CensoApi {
        get {
            self[CensoApiProviderEnvironmentKey.self]
        }
        set {
            self[CensoApiProviderEnvironmentKey.self] = newValue
        }
    }
}
