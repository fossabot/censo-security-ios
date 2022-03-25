//
//  Networking+Environment.swift
//  Strike
//
//  Created by Ata Namvari on 2021-03-11.
//

import Foundation
import SwiftUI
import Moya

// StrikeApi

struct StrikeApiProviderEnvironmentKey: EnvironmentKey {
    static var defaultValue = StrikeApi()
}

extension EnvironmentValues {
    var strikeApi: StrikeApi {
        get {
            self[StrikeApiProviderEnvironmentKey.self]
        }
        set {
            self[StrikeApiProviderEnvironmentKey.self] = newValue
        }
    }
}
