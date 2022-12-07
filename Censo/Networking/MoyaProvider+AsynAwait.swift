//
//  MoyaProvider+AsynAwait.swift
//  Censo
//
//  Created by Ata Namvari on 2022-03-10.
//

import Foundation
import Moya

extension MoyaProvider {
    func request(_ target: Target) async throws -> Moya.Response {
        try await withCheckedThrowingContinuation { continuation in
            request(target) { result in
                continuation.resume(with: result)
            }
        }
    }

    func request<T: Decodable>(_ target: Target) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            decodableRequest(target) { result in
                continuation.resume(with: result)
            }
        }
    }
}
