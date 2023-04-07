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
                switch result {
                case .success(let response) where response.statusCode < 400:
                    continuation.resume(with: result)
                case .success(let response):
                    continuation.resume(throwing: MoyaError.statusCode(response))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
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
