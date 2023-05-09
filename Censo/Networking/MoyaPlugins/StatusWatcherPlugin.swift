//
//  StatusWatcherPlugin.swift
//  Censo
//
//  Created by Ata Namvari on 2023-05-09.
//

import Foundation
import Moya

struct StatusWatcherPlugin: Moya.PluginType {
    var onReceive: (Int) -> Void

    func process(_ result: Result<Moya.Response, MoyaError>, target: Moya.TargetType) -> Result<Moya.Response, MoyaError> {
        switch (result, target) {
        case (.success(let response), _):
            DispatchQueue.main.async {
                onReceive(response.statusCode)
            }

            return result
        default:
            return result
        }
    }
}
