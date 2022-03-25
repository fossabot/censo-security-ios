//
//  Moya+AuthProvider.swift
//  Strike
//
//  Created by Ata Namvari on 2021-03-24.
//

import Foundation
import Moya

extension MoyaProvider {
    convenience init(authProvider: AuthProvider) {
        self.init(
            stubClosure: { _ in
                #if STUBBED
                return StubBehavior.delayed(seconds: 1)
                #else
                return StubBehavior.never
                #endif
            },
            plugins: [AuthProviderPlugin(authProvider: authProvider)]
        )
    }
}
