//
//  StrikeApi+AuthenticatedBlockhash.swift
//  Strike
//
//  Created by Ata Namvari on 2022-03-10.
//

import Foundation
import Moya
import LocalAuthentication

extension MoyaProvider where Target == StrikeApi.Target {
    func requestWithRecentBlockhash(_ target: @escaping (StrikeApi.Blockhash) -> Target, completion: @escaping (Result<Moya.Response, Error>) -> Void) {
        let context = LAContext()

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            completion(.failure(BiometryError.required))
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Identify yourself") { (success, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                self.decodableRequest(.recentBlockHash) { [weak self] (result: Result<StrikeApi.Blockhash, MoyaError>) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let blockhash):
                        let finalTarget = target(blockhash)
                        self?.request(finalTarget) { result in
                            switch result {
                            case .success(let response):
                                completion(.success(response))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                }
            }
        }
    }
}
