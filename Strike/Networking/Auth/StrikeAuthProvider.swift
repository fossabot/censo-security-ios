//
//  StrikeAuthProvider.swift
//  Strike
//
//  Created by Ata Namvari on 2022-08-15.
//

import Foundation
import JWTDecode
import Moya

class StrikeAuthProvider: ObservableObject {
    private let apiProvider = MoyaProvider<StrikeApi.Target>()

    struct JWTToken: Codable {
        var token: String
        var expiration: Date

        var isExpired: Bool {
            Date() > expiration
        }

        enum JWTError: Error {
            case noExpirationClaim
        }

        enum CodingKeys: String, CodingKey {
            case token
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let token = try container.decode(String.self, forKey: .token)
            let decodedJWT = try decode(jwt: token)

            self.token = token

            if let expiration = decodedJWT.expiresAt {
                self.expiration = expiration
            } else {
                throw JWTError.noExpirationClaim
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(token, forKey: .token)
        }
    }

    func authenticate(_ credentials: StrikeApi.Credentials, completion: @escaping (Error?) -> Void) {
        apiProvider.decodableRequest(.login(credentials)) { [weak self] (result: Result<JWTToken, MoyaError>) in
            self?.objectWillChange.send()

            switch result {
            case .success(let token):
                Self.storeCredentials(token)
                completion(nil)
            case .failure(let error): // TODO: ParsErrors
                completion(error)
            }
        }
    }
}

extension StrikeAuthProvider {
    static private let credentialsService = "com.strikeprotocols.credentials"

    var storedJWTToken: JWTToken? {
        guard let tokenData = Keychain.load(account: Self.credentialsService, service: Self.credentialsService) else {
            return nil
        }

        let decoder = JSONDecoder()

        do {
            return try decoder.decode(JWTToken.self, from: tokenData)
        } catch {
            return nil
        }
    }

    @discardableResult
    static func storeCredentials(_ jwtToken: JWTToken) -> Bool {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(jwtToken)
            return Keychain.save(account: Self.credentialsService, service: Self.credentialsService, data: data)
        } catch {
            return false
        }
    }

    static func clearStoredCredentials() {
        Keychain.clear(account: Self.credentialsService, service: Self.credentialsService)
    }
}

extension StrikeAuthProvider: AuthProvider {
    var isAuthenticated: Bool {
        storedJWTToken != nil
    }

    var isExpired: Bool {
        storedJWTToken?.isExpired ?? false
    }

    var bearerToken: String? {
        storedJWTToken?.token
    }

    enum RefreshError: Error {
        case tokenNonRefreshable
    }

    func refresh(completion: @escaping (Error?) -> Void) {
        invalidate()

        completion(RefreshError.tokenNonRefreshable)
    }

    func invalidate() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
        
        Self.clearStoredCredentials()
    }
}