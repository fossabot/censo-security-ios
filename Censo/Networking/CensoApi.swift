//
//  CensoApi.swift
//  Censo
//
//  Created by Donald Ness on 12/28/20.
//

import Foundation
import CryptoKit

import Moya

struct CensoApi {
    
    /// The Moya Target definition for this API.
    enum Target {
        case minVersion

        case login(Credentials)
        case resetPassword(String)

        case verifyUser(devicePublicKey: String?)
        case registerDevice(UserDevice, devicePublicKey: String)
        case addWalletSigners(AddSignersRequest, devicePublicKey: String)
        case approvalRequests
        case registerApprovalDisposition(ApprovalDispositionPayload, devicePublicKey: String)

        case registerPushToken(String, deviceIdentifier: String)
        case unregisterPushToken(deviceIdentifier: String)
        case connectDApp(code: String)
    }
    
    /// The provider for the Moya Target definition for this API.
    let provider: MoyaProvider<Target>
    
    init(
        authProvider: AuthProvider? = nil,
        stubClosure: @escaping MoyaProvider<Target>.StubClosure = CensoApi.defaultStubBehaviorClosure()
    ) {
        self.provider = MoyaProvider<Target>(
            requestClosure: Self.authTokenEndpointResolver(authProvider: authProvider),
            stubClosure: stubClosure,
            plugins: [
                AuthProviderPlugin(authProvider: authProvider)
            ]
        )
    }
    
    fileprivate static func defaultStubBehaviorClosure() -> MoyaProvider<Target>.StubClosure {
        return MoyaProvider.neverStub
    }
    
    fileprivate static func authTokenEndpointResolver(authProvider: AuthProvider?, callbackQueue: DispatchQueue = .main) -> MoyaProvider<Target>.RequestClosure {
        return { [weak authProvider] endpoint, closure in
            let originalRequest: URLRequest

            do {
                originalRequest = try endpoint.urlRequest()
            } catch {
                closure(.failure(.underlying(error, nil)))
                return
            }

            func attemptRequest() {
                closure(.success(originalRequest))
            }

            guard let authProvider = authProvider, authProvider.isExpired else {
                // In the case user is not authenticated or their token has expired,
                // proceed with the original request.  This will allow the caller
                // to respond to 401 responses appropriately.
                attemptRequest()
                return
            }

            DispatchQueue.refreshTokenDispatchQueue.async {
                DispatchGroup.refreshTokenDispatchGroup.wait()

                guard authProvider.isExpired else {
                    callbackQueue.async {
                        attemptRequest()
                    }
                    return
                }

                DispatchGroup.refreshTokenDispatchGroup.enter()

                authProvider.refresh { (error) in
                    DispatchGroup.refreshTokenDispatchGroup.leave()

                    if let error = error {
                        callbackQueue.async {
                            closure(.failure(MoyaError.underlying(error, nil)))
                        }
                    } else {
                        callbackQueue.async {
                            closure(.success(originalRequest))
                        }
                    }
                }
            }
        }
    }
}

extension DispatchGroup {
    fileprivate static let refreshTokenDispatchGroup = DispatchGroup()
}

extension DispatchQueue {
    fileprivate static let refreshTokenDispatchQueue = DispatchQueue(label: "com.censocustody.authorization-queue")
}

enum ApiError: Error, Equatable {
    case other(String)
}

extension CensoApi {
    enum Credentials: Encodable {
        case password(email: String, password: String)
        case signature(email: String, deviceKey: DeviceKey)

        enum CodingKeys: String, CodingKey {
            case credentials
            case deviceId
        }

        enum CredentialsCodingKeys: String, CodingKey {
            case type
            case email
            case password
            case timestamp
            case timestampSignature
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(UIDevice.current.identifierForVendor?.uuidString ?? "", forKey: .deviceId)

            var credentialsContainer = container.nestedContainer(keyedBy: CredentialsCodingKeys.self, forKey: .credentials)

            switch self {
            case .password(let email, let password):
                try credentialsContainer.encode("PasswordBased", forKey: .type)
                try credentialsContainer.encode(email, forKey: .email)
                try credentialsContainer.encode(password, forKey: .password)
            case .signature(let email, let deviceKey):
                let date = Date()
                try credentialsContainer.encode("SignatureBased", forKey: .type)
                try credentialsContainer.encode(email, forKey: .email)
                try credentialsContainer.encode(date, forKey: .timestamp)

                let dateString = DateFormatter.iso8601Full.string(from: date)
                let signature = try deviceKey.signature(for: dateString.data(using: .utf8)!).base64EncodedString()

                try credentialsContainer.encode(signature, forKey: .timestampSignature)
            }
        }
    }

    struct User: Codable, Identifiable {
        let id: String
        let fullName: String
        let loginName: String
        let hasApprovalPermission: Bool
        let organization: Organization
        let useStaticKey: Bool
        let publicKeys: [PublicKey]
        let deviceKey: String?
    }

    struct PublicKey: Codable {
        let key: String
        let chain: Chain
    }
    
    struct Organization: Codable {
        let id: String
        let name: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
        }
    }

    struct WalletSigner: Codable {
        let publicKey: String
        let chain: Chain
    }
    
    struct UserImage: Codable {
        let image: String
        let type: LogoType
        let signature: String
    }
    
    struct UserDevice: Codable {
        let publicKey: String
        let deviceType: DeviceType
        let userImage: UserImage
    }
    
    struct AddSignersRequest: Codable {
        let signers: [WalletSigner]
        let signature: String
    }

    struct ConnectedWallet: Codable {
        struct DAppInfo: Codable {
            let name: String
            let description: String
            let logo: URL?
        }

        let dappInfo: DAppInfo
    }

    struct WalletConnectionError: Codable, Error {
        struct Description: Codable {
            let message: String
        }

        let errors: [Description]
    }

    struct ApprovalDispositionPayload: Encodable {
        var requestID: String
        var approvalDisposition: ApprovalDisposition
        var signatures: [SignatureInfo]
    }
}

struct AuthProviderPlugin: Moya.PluginType {

    weak var authProvider: AuthProvider?

    func prepare(_ request: URLRequest, target: Moya.TargetType) -> URLRequest {
        var request = request

        switch target {
        case CensoApi.Target.minVersion:
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

// MARK: - Moya Target

extension CensoApi.Target {
    var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(.iso8601Full)
        return encoder
    }
}

extension CensoApi.Target: Moya.TargetType {
    var baseURL: URL {
        switch self {
        case .resetPassword:
            return Configuration.censoAuthBaseURL
        case .minVersion:
            return Configuration.minVersionURL
        default:
            return Configuration.apiBaseURL
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "v1/login"
        case .verifyUser:
            return "v1/users"
        case .registerDevice:
            return "v1/user-devices"
        case .addWalletSigners:
            return "v3/wallet-signers"
        case .approvalRequests:
            return "v2/approval-requests"
        case .registerPushToken:
            return "v1/notification-tokens"
        case .unregisterPushToken(let deviceIdentifier):
            return "v1/notification-tokens/\(deviceIdentifier)/ios"
        case .connectDApp:
            return "v1/wallet-connect"
        case .registerApprovalDisposition(let request, _):
            return "v2/approval-requests/\(request.requestID)/dispositions"
        case .minVersion:
            return ""
        case .resetPassword(let email):
            return "email/\(email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "[INVALID_EMAIL]")/reset"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .verifyUser,
             .approvalRequests,
             .minVersion:
            return .get
        case .connectDApp,
             .addWalletSigners,
             .registerApprovalDisposition,
             .resetPassword,
             .registerPushToken,
             .registerDevice,
             .login:
            return .post
        case .unregisterPushToken:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .login(let credentials):
            return .requestCustomJSONEncodable(credentials, encoder: encoder)
        case .verifyUser,
             .approvalRequests,
             .resetPassword,
             .minVersion:
            return .requestPlain
        case .addWalletSigners(let signers, _):
            return .requestJSONEncodable(signers)
        case .registerPushToken(let token, let deviceIdentifier):
            #if DEBUG
            return .requestJSONEncodable([
                "deviceType": "ios_test",
                "deviceId": deviceIdentifier,
                "token": token
            ])
            #else
            return .requestJSONEncodable([
                "deviceType": "ios",
                "deviceId": deviceIdentifier,
                "token": token
            ])
            #endif
        case .unregisterPushToken:
            return .requestPlain
        case .registerDevice(let userDevice, _):
            return .requestJSONEncodable(userDevice)
        case .connectDApp(let code):
            return .requestJSONEncodable([
                "uri": code
            ])
        case .registerApprovalDisposition(let request, _):
            return .requestJSONEncodable(request)
        }
    }
    
    var sampleData: Data {
        switch self {
        case .verifyUser:
            return Mock.censoApi.sampleData.verifyUser()
        default:
            return Data()
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .login(.signature(_, let deviceKey)):
            return [
                "Content-Type": "application/json",
                "X-IsApi": "true",
                "X-Censo-Device-Identifier": (try? deviceKey.publicExternalRepresentation().base58String) ?? "[DEVICE_KEY_ERROR]"
            ]
        case .addWalletSigners(_, let devicePublicKey),
             .registerApprovalDisposition(_, let devicePublicKey),
             .registerDevice(_, let devicePublicKey),
             .verifyUser(.some(let devicePublicKey)):
            return [
                "Content-Type": "application/json",
                "X-IsApi": "true",
                "X-Censo-Device-Identifier": devicePublicKey
            ]
        default:
            return [
                "Content-Type": "application/json",
                "X-IsApi": "true"
            ]
        }
    }
}

extension CensoApi.User: CustomStringConvertible {
    var description: String {
        return "\(fullName) <\(loginName)>"
    }
}
