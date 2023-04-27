//
//  CensoAuthProvider.swift
//  Censo
//
//  Created by Ata Namvari on 2022-08-15.
//

import Foundation
import JWTDecode
import Moya

class CensoAuthProvider: ObservableObject {
    private let apiProvider = MoyaProvider<CensoApi.Target>()

    enum AuthenticatedState {
        case deviceAuthenticatedRegistered(RegisteredDevice, token: JWTToken)
        case deviceAuthenticatedUnregistered(DeviceKey, token: JWTToken)
        case emailAuthenticated(DeviceKey, token: JWTToken)
    }

    @Published var authenticatedState: AuthenticatedState? {
        didSet {
            switch authenticatedState {
            case .none:
                self.token = nil
            case .deviceAuthenticatedRegistered(_, let token),
                 .deviceAuthenticatedUnregistered(_, let token),
                 .emailAuthenticated(_, let token):
                self.token = token
            }
        }
    }

    private var token: JWTToken?

    struct JWTToken: Codable {
        var email: String
        var token: String
        var expiration: Date
        var emailVerificationLogin: Bool

        var isExpired: Bool {
            Date() > expiration
        }

        enum JWTError: Error {
            case noExpirationClaim
            case noEmailInBody
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

            if let email = decodedJWT.body["email"] as? String {
                self.email = email
            } else {
                throw JWTError.noEmailInBody
            }

            if let emailVerificationLogin = decodedJWT.body["emailVerificationLogin"] as? Bool {
                self.emailVerificationLogin = emailVerificationLogin
            } else {
                self.emailVerificationLogin = true
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(token, forKey: .token)
        }
    }

    func exchangeTokenIfNeeded(deviceKey: PreauthenticatedKey<DeviceKey>) async throws {
        switch authenticatedState {
        case .some(.deviceAuthenticatedRegistered),
             .some(.deviceAuthenticatedUnregistered),
             .none:
            break
        case .emailAuthenticated(_, let token):
            let timestamp = Date()
            let dateString = DateFormatter.iso8601Full.string(from: timestamp)
            let signature = try deviceKey.signature(for: dateString.data(using: .utf8)!).base64EncodedString()
            let newToken: JWTToken = try await apiProvider.request(.login(.signature(email: token.email, timestamp: timestamp, signature: signature, publicKey: try deviceKey.key.publicExternalRepresentation().base58String)))
            self.token = newToken
        }
    }
}

//extension CensoAuthProvider {
//    static private let credentialsService = "com.censocustody.credentials"
//
//    var storedJWTToken: JWTToken? {
//        do {
//            guard let tokenData = try Keychain.load(account: Self.credentialsService, service: Self.credentialsService) else {
//                return nil
//            }
//
//            let decoder = JSONDecoder()
//
//            return try decoder.decode(JWTToken.self, from: tokenData)
//        } catch {
//            return nil
//        }
//    }
//
//    @discardableResult
//    static func storeCredentials(_ jwtToken: JWTToken) -> Bool {
//        let encoder = JSONEncoder()
//        do {
//            let data = try encoder.encode(jwtToken)
//            try Keychain.save(account: Self.credentialsService, service: Self.credentialsService, data: data)
//            return true
//        } catch {
//            return false
//        }
//    }
//
//    static func clearStoredCredentials() {
//        Keychain.clear(account: Self.credentialsService, service: Self.credentialsService)
//    }
//}

extension CensoAuthProvider: AuthProvider {
    var isAuthenticated: Bool {
        //storedJWTToken != nil
        token != nil
    }

    var isExpired: Bool {
        //storedJWTToken?.isExpired ?? false
        token?.isExpired ?? false
    }

    var bearerToken: String? {
        //storedJWTToken?.token
        token?.token
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
        
        //Self.clearStoredCredentials()
        authenticatedState = nil
    }
}
