//
//  AuhtProviderPlugin.swift
//  Censo
//
//  Created by Ata Namvari on 2023-05-09.
//

import Foundation
import Moya

struct AuthProviderPlugin: Moya.PluginType {

    weak var authProvider: AuthProvider?

    func prepare(_ request: URLRequest, target: Moya.TargetType) -> URLRequest {
        var request = request

        switch target {
        case CensoApi.Target.minVersion,
             CensoApi.Target.login:
            break
        default:
            if let authProvider = authProvider, authProvider.isAuthenticated, let token = authProvider.bearerToken {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                debugPrint("Unauthenticated request: \(request)")
            }
        }

        return request
    }

    func process(_ result: Result<Moya.Response, MoyaError>, target: Moya.TargetType) -> Result<Moya.Response, MoyaError> {
        switch (result, target) {
        case (.success(let response), _) where response.statusCode == 401:
            debugPrint("401 unauthorized:", String(data: response.data, encoding: .utf8)!)
            defer { authProvider?.invalidate() }
            return result
        default:
            return result
        }
    }
}
