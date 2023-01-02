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
        case login(Credentials)

        case verifyUser
        case walletSigners
        case userDevices
        case addWalletSigners(Signers)
        case approvalRequests
        case registerApprovalDisposition(ApprovalDispositionRequest)
        case multipleAccountNonce(GetMultipleAccountsRequest)
        case initiateRequest(InitiationRequest)

        case registerPushToken(String, deviceIdentifier: String)
        case unregisterPushToken(deviceIdentifier: String)
        case connectDApp(code: String)

        case resetPassword(String)

        case minVersion
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

extension Data: SolanaSignable {
    func signableData(approverPublicKey: String) throws -> Data {
        self
    }
}

enum ApiError: Error, Equatable {
    case other(String)
}

extension CensoApi {
    enum Credentials: Encodable {
        case password(email: String, password: String)
        case signature(email: String, privateKeys: PrivateKeys? = nil)

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
            case .signature(let email, .none):
                let date = Date()
                try credentialsContainer.encode("SignatureBased", forKey: .type)
                try credentialsContainer.encode(email, forKey: .email)
                try credentialsContainer.encode(date, forKey: .timestamp)

                let dateString = DateFormatter.iso8601Full.string(from: date)

                let privateKeys = try Keychain.privateKeys(email: email)
                let signature = try privateKeys.signature(for: dateString.data(using: .utf8)!, chain: .solana)

                try credentialsContainer.encode(signature, forKey: .timestampSignature)
            case .signature(let email, .some(let privateKeys)):
                let date = Date()
                try credentialsContainer.encode("SignatureBased", forKey: .type)
                try credentialsContainer.encode(email, forKey: .email)
                try credentialsContainer.encode(date, forKey: .timestamp)

                let dateString = DateFormatter.iso8601Full.string(from: date)

                let signature = try privateKeys.signature(for: dateString.data(using: .utf8)!, chain: .solana)

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
        let signature: String
    }
    
    struct UserImage: Codable {
        let image: String
        let type: LogoType
        let signature: String
    }
    
    enum DeviceType: String, Codable {
        case ios = "ios"
    }
    
    struct UserDevice: Codable {
        let publicKey: String
        let deviceType: DeviceType
        let userImage: UserImage
    }
    
    struct Signers: Codable {
        let signers: [WalletSigner]
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

    struct GetMultipleAccountsRequest: Encodable {
        struct Params: Codable {
            var commitment = Configuration.solanaCommitment
            var encoding = "base64"
        }

        enum ParamItem: Encodable {
            case stringList([String])
            case params(Params)

            func encode(to encoder: Encoder) throws {
                switch self {
                case .stringList(let value):
                    try value.encode(to: encoder)
                case .params(let value):
                    try value.encode(to: encoder)
                }
            }
        }

        var id = UUID().uuidString
        var method = "getMultipleAccounts"
        var jsonrpc = "2.0"
        var params: [ParamItem]

        init(accountKeys: [String]) {
            self.params = [
                .stringList(accountKeys),
                .params(Params())
            ]
        }
    }

    struct Nonce: Decodable, Equatable {
        var value: String

        init(_ value: String) {
            self.value = value
        }

        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            let stringValue = try container.decode(String.self)

            if let value = Data(base64Encoded: stringValue)?.subdata(in: 40 ..< 72).base58String {
                self.value = value
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid Nonce")
            }
        }
    }

    struct GetMultipleAccountsResponse: Decodable {
        struct Result: Decodable {
            struct AccountData: Decodable {
                let data: Nonce
            }
            struct Context: Decodable {
                let slot: UInt64
            }
            
            let context: Context
            let value: [AccountData]
        }

        let id: String
        let result: Result
        
        var slot: UInt64 {
            result.context.slot
        }

        var nonces: [Nonce] {
            result.value.map(\.data)
        }
    }

    struct ApprovalDispositionRequest: Encodable {
        let disposition: ApprovalDisposition
        let requestID: String
        let requestType: SolanaApprovalRequestType
        let nonces: [Nonce]
        let email: String

        enum CodingKeys: String, CodingKey {
            case signatureInfo
            case approvalDisposition
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            let privateKeys = try Keychain.privateKeys(email: email)
            let approverPublicKey = privateKeys.publicKey(for: .solana)
            let signatureInfo: SignatureType = try
            {
                switch requestType {
                case .loginApproval, .acceptVaultInvitation, .passwordReset:
                    return try offChainSign(chain: .solana, privateKeys: privateKeys, approverPublicKey: approverPublicKey)
                case .walletCreation(let walletCreation):
                    return try sign(chain: walletCreation.accountInfo.chain ?? Chain.solana, privateKeys: privateKeys, approverPublicKey: approverPublicKey)
                case .addressBookUpdate(let request):
                    return try sign(chain: request.chain, privateKeys: privateKeys, approverPublicKey: approverPublicKey)
                case .withdrawalRequest(let request):
                    switch (request.signingData) {
                    case .bitcoin(let signingData):
                        let derivationPath = DerivationNode.notHardened(signingData.childKeyIndex)
                        return .bitcoin(
                            BitcoinSignatures(
                                signatures: try signableDataList(approverPublicKey: approverPublicKey).map({
                                    try privateKeys.signature(for: $0, chain: .bitcoin, derivationPath: derivationPath)
                                })
                            )
                        )
                    case .ethereum:
                        return .ethereum(
                            EthereumSignature(
                                signature: try privateKeys.signature(
                                    for: signableData(approverPublicKey: approverPublicKey),
                                    chain: .solana
                                )
                            )
                        )
                    default:
                        break
                    }
                    fallthrough
                default:
                    return try sign(chain: Chain.solana, privateKeys: privateKeys, approverPublicKey: approverPublicKey)
                }
            }()

            try container.encode(disposition.rawValue, forKey: .approvalDisposition)
            try container.encode(signatureInfo, forKey: .signatureInfo)
        }
        
        private func offChainSign(chain: Chain, privateKeys: PrivateKeys, approverPublicKey: String) throws -> SignatureType {
            let dataToSign = try signableData(approverPublicKey: approverPublicKey)
            return .nochain(
                NoChainSignature(
                    signature: try privateKeys.signature(for: dataToSign, chain: chain),
                    signedData: dataToSign.base64EncodedString()
                )
            )
        }
        
        private func sign(chain: Chain, privateKeys: PrivateKeys, approverPublicKey: String) throws -> SignatureType {
            let dataToSign = try signableData(approverPublicKey: approverPublicKey)
            
            switch (chain) {
            case .bitcoin:
                return try offChainSign(chain: chain, privateKeys: privateKeys, approverPublicKey: approverPublicKey)
            case .ethereum:
                return try offChainSign(chain: chain, privateKeys: privateKeys, approverPublicKey: approverPublicKey)
            case .solana:
                if let nonce = nonces.first, let nonceAccountAddress = requestType.nonceAccountAddresses.first {
                    return .solana(
                        SolanaSignature(
                            signature: try privateKeys.signature(for: dataToSign, chain: .solana),
                            nonce: nonce.value,
                            nonceAccountAddress: nonceAccountAddress
                        )
                    )
                } else {
                    throw ApiError.other("cannot create solana signature with no nonce data")
                }
            }
        }
    }
    
    struct InitiationRequest: Encodable {
        let disposition: ApprovalDisposition
        let requestID: String
        let initiation: MultisigOpInitiation
        let requestType: SolanaApprovalRequestType
        let nonces: [Nonce]
        let email: String
        let opAccountPrivateKey: Curve25519.Signing.PrivateKey

        enum CodingKeys: String, CodingKey {
            case initiatorSignature
            case approvalDisposition
            case nonce
            case nonceAccountAddress
            case opAccountAddress
            case opAccountSignature
            case supplyDappInstructions
        }

        private struct SupplyDappInstructionsTxSignature: Encodable {
            let nonce: String
            let nonceAccountAddress: String
            let signature: String
        }

        private struct SupplyDAppInstructions: Encodable {
            let supplyInstructionInitiatorSignatures: [SupplyDappInstructionsTxSignature]
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            if let nonce = nonces.first, let nonceAccountAddress = requestType.nonceAccountAddresses.first {
                try container.encode(nonce.value, forKey: .nonce)
                try container.encode(nonceAccountAddress, forKey: .nonceAccountAddress)
            }

            try container.encode(disposition.rawValue, forKey: .approvalDisposition)

            let privateKeys = try Keychain.privateKeys(email: email)
            let approverPublicKey = privateKeys.publicKey(for: .solana)
            let initiatorSignature = try privateKeys.signature(for: signableData(approverPublicKey: approverPublicKey), chain: .solana)
            try container.encode(initiatorSignature, forKey: .initiatorSignature)
            try container.encode(try self.opAccountPublicKey.base58EncodedString, forKey: .opAccountAddress)
            let ephemeralSignature = try opAccountPrivateKey.signature(for: signableData(approverPublicKey: approverPublicKey)).base64EncodedString()
            try container.encode(ephemeralSignature, forKey: .opAccountSignature)

            if try !supplyInstructions.isEmpty {
                let supplyDappInstructions = SupplyDAppInstructions(
                    supplyInstructionInitiatorSignatures: try supplyInstructions.map({ instruction in
                        SupplyDappInstructionsTxSignature(
                            nonce: instruction.nonce.value,
                            nonceAccountAddress: instruction.nonceAccountAddress,
                            signature: try privateKeys.signature(for: instruction.signableData(approverPublicKey: approverPublicKey), chain: .solana)
                        )
                    })
                )
                
                try container.encode(supplyDappInstructions, forKey: .supplyDappInstructions)
            }
        }
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

extension String: SolanaSignable {
    func signableData(approverPublicKey: String) throws -> Data {
        data(using: .utf8) ?? Data()
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
        case .multipleAccountNonce:
            return Configuration.solanaRpcURL
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
        case .userDevices:
            return "v1/user-devices"
        case .walletSigners:
            return "v1/wallet-signers"
        case .addWalletSigners:
            return "v2/wallet-signers"
        case .approvalRequests:
            return "v1/approval-requests"
        case .registerPushToken:
            return "v1/notification-tokens"
        case .unregisterPushToken(let deviceIdentifier):
            return "v1/notification-tokens/\(deviceIdentifier)/ios"
        case .connectDApp:
            return "v1/wallet-connect"
        case .registerApprovalDisposition(let request):
            return "v1/approval-requests/\(request.requestID)/dispositions"
        case .multipleAccountNonce,
             .minVersion:
            return ""
        case .initiateRequest(let request):
            return "v1/approval-requests/\(request.requestID)/initiations"
        case .resetPassword(let email):
            return "email/\(email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "[INVALID_EMAIL]")/reset"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .verifyUser,
             .walletSigners,
             .approvalRequests,
             .minVersion:
            return .get
        case .connectDApp,
             .addWalletSigners,
             .multipleAccountNonce,
             .registerApprovalDisposition,
             .initiateRequest,
             .resetPassword,
             .registerPushToken,
             .userDevices,
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
             .walletSigners,
             .approvalRequests,
             .resetPassword,
             .minVersion:
            return .requestPlain
        case .addWalletSigners(let signers):
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
        case .userDevices:
            return .requestPlain
        case .connectDApp(let code):
            return .requestJSONEncodable([
                "uri": code
            ])
        case .registerApprovalDisposition(let request):
            return .requestJSONEncodable(request)
        case .multipleAccountNonce(let request):
            return .requestJSONEncodable(request)
        case .initiateRequest(let request):
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
        case .multipleAccountNonce:
            return [:]
        default:
            return [
                "Content-Type": "application/json",
                "X-IsApi": "true",
                //"X-Censo-Device-Identifier": "TBD"
            ]
        }
    }
}

extension CensoApi.User: CustomStringConvertible {
    var description: String {
        return "\(fullName) <\(loginName)>"
    }
}