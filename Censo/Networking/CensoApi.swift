//
//  CensoApi.swift
//  Censo
//
//  Created by Donald Ness on 12/28/20.
//

import Foundation
import CryptoKit
import UIKit
import Moya
import Combine

struct CensoApi {
    
    /// The Moya Target definition for this API.
    enum Target {
        case minVersion

        case login(Credentials)
        case emailVerification(String)

        case verifyUser(devicePublicKey: String?)
        case registerDevice(UserDevice, devicePublicKey: String)
        case boostrapDeviceAndSigners(BootstrapUserDeviceAndSigners, devicePublicKey: String)
        case addWalletSigners(SignersInfo, devicePublicKey: String)
        case approvalRequests(devicePublicKey: String)
        case registerApprovalDisposition(ApprovalDispositionPayload, devicePublicKey: String)

        case registerPushToken(String, deviceIdentifier: String)
        case unregisterPushToken(deviceIdentifier: String)

        case availableDAppVaults(devicePublicKey: String)
        case connectDApp(WalletConnectPairingRequest, devicePublicKey: String)
        case checkDAppConnection(topic: String, devicePublicKey: String)

        case shards(policyRevisionId: String, userId: String?, deviceIdentifier: String)
        case recoveryShards(deviceIdentifier: String)
        
        case orgAdminRecoveredDeviceAndSigners(OrgAdminRecoveredDeviceAndSigners, devicePublicKey: String)
        case myOrgAdminRecoveryRequest(devicePublicKey: String)
        case registerOrgAdminRecoverySignatures(OrgAdminRecoverySignaturesRequest, devicePublicKey: String)
    }
    
    /// The provider for the Moya Target definition for this API.
    let provider: MoyaProvider<Target>

    let statusPublisher: PassthroughSubject<Status, Never>

    enum Status {
        case inMaintenance
    }
    
    init(
        authProvider: AuthProvider? = nil,
        stubClosure: @escaping MoyaProvider<Target>.StubClosure = CensoApi.defaultStubBehaviorClosure()
    ) {
        let statusPublisher = PassthroughSubject<Status, Never>()
        self.statusPublisher = statusPublisher

        self.provider = MoyaProvider<Target>(
            stubClosure: stubClosure,
            plugins: [
                AuthProviderPlugin(authProvider: authProvider),
                StatusWatcherPlugin(onReceive: { statusCode in
                    if statusCode == 418 {
                        statusPublisher.send(.inMaintenance)
                    }
                })
            ]
        )
    }
    
    fileprivate static func defaultStubBehaviorClosure() -> MoyaProvider<Target>.StubClosure {
        return MoyaProvider.neverStub
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
        case emailVerification(email: String, verificationToken: String)
        case signature(email: String, timestamp: Date, signature: String, publicKey: String)

        enum CodingKeys: String, CodingKey {
            case credentials
            case deviceId
        }

        enum CredentialsCodingKeys: String, CodingKey {
            case type
            case email
            case verificationToken
            case timestamp
            case timestampSignature
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(UIDevice.current.identifierForVendor?.uuidString ?? "", forKey: .deviceId)

            var credentialsContainer = container.nestedContainer(keyedBy: CredentialsCodingKeys.self, forKey: .credentials)

            switch self {
            case .emailVerification(let email, let password):
                try credentialsContainer.encode("EmailVerificationBased", forKey: .type)
                try credentialsContainer.encode(email, forKey: .email)
                try credentialsContainer.encode(password, forKey: .verificationToken)
            case .signature(let email, let timestamp, let signature, _):
                try credentialsContainer.encode("SignatureBased", forKey: .type)
                try credentialsContainer.encode(email, forKey: .email)
                try credentialsContainer.encode(timestamp, forKey: .timestamp)
                try credentialsContainer.encode(signature, forKey: .timestampSignature)
            }
        }
    }
    
    struct DeviceKeyInfo: Codable {
        let key: String
        let approved: Bool
        let bootstrapKey: String?
    }
    
    struct OrgAdminInfo: Codable {
        let hasRecoveryContract: Bool
        let participantId: String
        let hasPendingOrgRecovery: Bool
        let canInitiateOrgRecovery: Bool
    }

    struct User: Codable, Identifiable {
        let id: String
        let fullName: String
        let loginName: String
        let hasApprovalPermission: Bool
        let organization: Organization
        let publicKeys: [PublicKey]
        let deviceKeyInfo: DeviceKeyInfo?
        let userShardedToPolicyGuid: String?
        let shardingPolicy: ShardingPolicy?
        let canAddSigners: Bool
        let orgAdminInfo: OrgAdminInfo?
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
    
    struct UserDevice: Encodable {
        let publicKey: String
        let deviceType: DeviceType
        let userImage: UserImage
        let replacingDeviceIdentifier: String?
        let model: String
        let name: String

        init(publicKey: String, deviceType: DeviceType, userImage: UserImage, replacingDeviceIdentifier: String?) {
            self.publicKey = publicKey
            self.deviceType = deviceType
            self.userImage = userImage
            self.replacingDeviceIdentifier = replacingDeviceIdentifier
            self.model = UIDevice.current.model
            self.name = UIDevice.current.name
        }
    }
    
    struct ShardCopy: Codable {
        let encryptionPublicKey: String
        let encryptedData: String
    }
    
    struct Shard: Codable {
        let participantId: String
        let shardCopies: [ShardCopy]
        let shardId: String?
        let parentShardId: String?
    }

    struct Share: Codable {
        let policyRevisionId: String
        let shards: [Shard]
    }
    
    struct RecoveryShard: Codable {
        let shardId: String
        let encryptedData: String
    }
    
    struct AncestorShard: Codable {
        let shardId: String
        let participantId: String
        let parentShardId: String?
    }
    
    struct ShardsResponse: Codable {
        struct Shard: Codable {
            let participantId: String
            let shardCopies: [ShardCopy]
            let shardId: String
            let parentShardId: String?
        }

        let shards: [Shard]
    }

    struct RecoveryShardsResponse: Codable {
        let shards: [Shard]
        let ancestors: [AncestorShard]
    }
    
    struct SignersInfo: Codable {
        let signers: [WalletSigner]
        let signature: String
        let share: Share
    }
    
    struct BootstrapDevice: Codable {
        let publicKey: String
        let signature: String
    }
    
    struct BootstrapUserDeviceAndSigners: Encodable {
        let userDevice: UserDevice
        let bootstrapDevice: BootstrapDevice
        let signersInfo: SignersInfo
    }
    
    struct OrgAdminRecoveredDeviceAndSigners: Encodable {
        let userDevice: UserDevice
        let signersInfo: SignersInfo
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
        var shards: [Shard]?
        var recoveryShards: [RecoveryShard]?
    }

    struct WalletConnectPairing: Codable {
        var topic: String
    }

    struct WalletConnectSession: Codable {
        var topic: String
        var name: String
        var url: String
        var description: String
        var icons: [String]
        var status: WalletconnectSessionStatus
        var wallets: [String]
    }

    enum WalletconnectSessionStatus: String, Codable {
        case rejected = "Rejected"
        case active = "Active"
        case expired = "Expired"
        case deleted = "Deleted"
    }

    struct AvailableDAppVault: Codable {
        var vaultName: String
        var wallets: [AvailableDAppWallet]
    }

    struct AvailableDAppWallet: Codable {
        var walletName: String
        var walletAddress: String
        var chains: [Chain]
    }

    struct AvailableDAppVaultsResponse: Codable {
        var vaults: [AvailableDAppVault]
    }

    struct WalletConnectPairingRequest: Codable {
        var uri: String
        var walletAddresses: [String]
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
        case .boostrapDeviceAndSigners:
            return "v1/bootstrap-user-devices"
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
        case .checkDAppConnection(let topic, _):
            return "v1/wallet-connect/\(topic)"
        case .registerApprovalDisposition(let request, _):
            return "v2/approval-requests/\(request.requestID)/dispositions"
        case .minVersion:
            return ""
        case .emailVerification:
            return "v1/verification-token"
        case .shards:
            return "v1/shards"
        case .recoveryShards:
            return "v1/recovery-shards"
        case .orgAdminRecoveredDeviceAndSigners:
            return "v1/org-admin-recovered-devices"
        case .myOrgAdminRecoveryRequest:
            return "v1/my-org-admin-recovery-request"
        case .registerOrgAdminRecoverySignatures:
            return "v1/org-admin-recovery-signatures"
        case .availableDAppVaults:
            return "v1/available-dapp-wallets"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .verifyUser,
             .approvalRequests,
             .minVersion,
             .shards,
             .recoveryShards,
             .checkDAppConnection,
             .availableDAppVaults,
             .myOrgAdminRecoveryRequest:
            return .get
        case .connectDApp,
             .addWalletSigners,
             .boostrapDeviceAndSigners,
             .orgAdminRecoveredDeviceAndSigners,
             .registerApprovalDisposition,
             .emailVerification,
             .registerPushToken,
             .registerDevice,
             .registerOrgAdminRecoverySignatures,
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
             .minVersion,
             .recoveryShards,
             .checkDAppConnection,
             .availableDAppVaults,
             .myOrgAdminRecoveryRequest:
            return .requestPlain
        case .emailVerification(let email):
            return .requestJSONEncodable([
                "email": email
            ])
        case .shards(let policyRevisionId, let userId, _):
             var params: [String: Any] = [:]
             params["policy-revision-id"] = policyRevisionId
             params["user-id"] = userId
             return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
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
        case .boostrapDeviceAndSigners(let bootstrapDeviceAndSigners, _):
            return .requestJSONEncodable(bootstrapDeviceAndSigners)
        case .orgAdminRecoveredDeviceAndSigners(let orgAdminRecoveredDeviceAndSigners, _):
            return .requestJSONEncodable(orgAdminRecoveredDeviceAndSigners)
        case .registerOrgAdminRecoverySignatures(let orgAdminRecoverySignaturesRequest, _):
            return .requestJSONEncodable(orgAdminRecoverySignaturesRequest)
        case .connectDApp(let request, _):
            return .requestJSONEncodable(request)
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
        case .login(.signature(_, _, _, let devicePublicKey)):
            return [
                "Content-Type": "application/json",
                "X-IsApi": "true",
                "X-Censo-Device-Identifier": devicePublicKey,
                "X-Censo-OS-Version": UIDevice.current.systemVersion,
                "X-Censo-Device-Type": UIDevice.current.systemName,
                "X-Censo-App-Version": Bundle.main.shortVersionString
            ]
        case .addWalletSigners(_, let devicePublicKey),
             .boostrapDeviceAndSigners(_, let devicePublicKey),
             .registerApprovalDisposition(_, let devicePublicKey),
             .registerDevice(_, let devicePublicKey),
             .verifyUser(.some(let devicePublicKey)),
             .shards(_, _, let devicePublicKey),
             .recoveryShards(let devicePublicKey),
             .approvalRequests(let devicePublicKey),
             .orgAdminRecoveredDeviceAndSigners(_, let devicePublicKey),
             .registerOrgAdminRecoverySignatures(_, let devicePublicKey),
             .myOrgAdminRecoveryRequest(let devicePublicKey),
             .availableDAppVaults(let devicePublicKey),
             .checkDAppConnection(_, let devicePublicKey),
             .connectDApp(_, let devicePublicKey):
            return [
                "Content-Type": "application/json",
                "X-IsApi": "true",
                "X-Censo-Device-Identifier": devicePublicKey,
                "X-Censo-OS-Version": UIDevice.current.systemVersion,
                "X-Censo-Device-Type": UIDevice.current.systemName,
                "X-Censo-App-Version": Bundle.main.shortVersionString
            ]
        default:
            return [
                "Content-Type": "application/json",
                "X-IsApi": "true",
                "X-Censo-OS-Version": UIDevice.current.systemVersion,
                "X-Censo-Device-Type": UIDevice.current.systemName,
                "X-Censo-App-Version": Bundle.main.shortVersionString
            ]
        }
    }
}

extension CensoApi.User: CustomStringConvertible {
    var description: String {
        return "\(fullName) <\(loginName)>"
    }
}

extension Bundle {
    var shortVersionString: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}
