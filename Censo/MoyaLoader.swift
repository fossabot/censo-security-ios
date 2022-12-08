//
//  MoyaLoadable.swift
//  Censo
//
//  Created by Ata Namvari on 2021-03-11.
//

import Foundation
import Moya

struct MoyaLoader<Value, Target>: Loadable where Target : Moya.TargetType, Value : Decodable {
    let provider: MoyaProvider<Target>
    let target: Target

    func load(_ completion: @escaping (Result<Value, Error>) -> ()) {
        provider.decodableRequest(target) { (result: Result<Value, MoyaError>) in
            completion(result.mapError { $0 })
        }
    }
}


extension MoyaProvider {
    func loader<Value>(for target: Target) -> MoyaLoader<Value, Target> {
        MoyaLoader(provider: self, target: target)
    }
}
