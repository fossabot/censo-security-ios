//
//  StrikeApi+Mock.swift
//  Strike
//
//  Created by Donald Ness on 2/17/21.
//

import Foundation
import Moya



extension StrikeApi {
    static func mock(
        authProvider: AuthProvider? = nil,
        stubClosure: @escaping MoyaProvider<StrikeApi.Target>.StubClosure = { _ in .immediate }
    ) -> StrikeApi {
        return StrikeApi(authProvider: authProvider, stubClosure: stubClosure)
    }
}
