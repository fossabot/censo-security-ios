//
//  CensoApi+Mock.swift
//  Censo
//
//  Created by Donald Ness on 2/17/21.
//

import Foundation
import Moya



extension CensoApi {
    static func mock(
        authProvider: AuthProvider? = nil,
        stubClosure: @escaping MoyaProvider<CensoApi.Target>.StubClosure = { _ in .immediate }
    ) -> CensoApi {
        return CensoApi(authProvider: authProvider, stubClosure: stubClosure)
    }
}
