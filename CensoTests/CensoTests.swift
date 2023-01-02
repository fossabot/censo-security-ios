//
//  CensoTests.swift
//  CensoTests
//
//  Created by Donald Ness on 12/23/20.
//

import XCTest
@testable import Censo
import CryptoKit

class CensoTests: XCTestCase {
    
    func testSignersUpdateSerializedOp() throws {
        let request: ApprovalRequest = getSignersUpdateApprovalRequest(nonceAccountAddresses: ["6XQy8HrrMmsfmajFpWo5tWhDUiESg8obA4NGWJwjNgpR"])
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("EHEtZUo7aAh5VqFvo5PUsfFm3oquJfK3hb8fEJgC4nwM")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.opHashData.toHexString(),
            "050b421acb7dfcb45b3fa41c345677eeee6a360e933ebfff2a321e6d6bf23f703a69ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c715000000000000000000000000000000000000000000000000000000000000000000000000000000002f2bb19a6e87510629e1b70680b474648391dc5d898c1f8431eb10c6fbb4cebb00016d50ef7d464988ec20f2782dccf74d4416779bbc5073d0168b12b6f720140656"
        )
    }

    func testSignersUpdateApprovalDisposition() throws {
        let request: ApprovalRequest = getApprovalRequest(getSignersUpdateRequestForApproval(nonceAccountAddresses: ["Deuspj2g5crN81b6GocKANAhB3Y5D6XseXjiT1bery7Z"]))
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("FURnHTusWpktnZfRCEWi3iCEY7D8FJTizNX2z9A4byps")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableData(approverPublicKey: "AztEBjLYWtNgBN3Gzqz5a2g4npNmtZQ29eidUzrKZwhX").toHexString(),
            "0201040869ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c715948d361ce4f9bafead45f21c7aec862985622a4c48cee98a4c6293ff70901446bc02853a9410a410b2d6ef666f054e84f35cc47885bf7e9c618eb581938f23941a8dd233c196130bce1a6d6bd2a122cea83c741ae3221705fb0d2074047956b906a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b210000000000000000000000000000000000000000000000000000000000000000000000000753be561ec13b0065ff6cdef40ac6ae7931c5b82501159ebc2751f3d72720f1d70a51898096a604916bc64710e1e55a46f6d82afd7b54c11d2982282c6f8f5802060302040004040000000703030105220901de59db38ce9ead210c8446f5aae7d31936bbd30c91e3b0fbca116ef80f8db7b6"
        )
    }

    func testSignersUpdateInitiationRequest() throws {
        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(accountSize: 3649, minBalanceForRentExemption: 26287920),
            initiatorIsApprover: true
        )
        let requestType: SolanaApprovalRequestType = getSignersUpdateRequest(nonceAccountAddresses: ["BEhPWZKJoFDHaaJ7qTqZ6cfkR1YKDssHwttBYnp9kZir"])
        let request = getWalletInitiationRequest(requestType, initiation: initiation)
        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "e754f36891ada48a4cfc71ee4673aa2c77ceaa47da3021e4b64cf56bc91df5d8".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: [CensoApi.Nonce("4oEYPeBwJBWzrbQ1c7jeeUGKWc1afDW7wFuhesE84GLr")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "kwwyzySTUJHWBF64u15iwv8bMvcHTNmZzfEh9iDeC7j").toHexString(),
            "0301040969ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c715e9cd9aec3dbf86f831f3a958fe0cacf766c96fe73a870935ae4a1dbc32f9690e0b421acb7dfcb45b3fa41c345677eeee6a360e933ebfff2a321e6d6bf23f703a981716351da1f0ee427fdbcb78f5c2d68ea47b7799000aaf333de3786d72c6532f2bb19a6e87510629e1b70680b474648391dc5d898c1f8431eb10c6fbb4cebb06a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b210000000000000000000000000000000000000000000000000000000000000000000000003fdc67ec334cbd120c7c9a2826105ef499faac1ec7ca09e6f91ba1cdc31dc236386b16ceef633922978f5ab1386e428471a2a8f74e2619f84101c2aec41821a30307030305000404000000070200013400000000301f910100000000410e0000000000003fdc67ec334cbd120c7c9a2826105ef499faac1ec7ca09e6f91ba1cdc31dc236080501040206006c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000016d50ef7d464988ec20f2782dccf74d4416779bbc5073d0168b12b6f72014065688c02d478b22653c2576e020b3482da4209fbdd77d35ee43cb522173e4c1b376"
        )
    }

    func testSolanaWalletCreationApprovalDisposition() throws {
        let request = getApprovalRequest(getSolanaWalletCreationRequest(nonceAccountAddresses: ["Hy4Ztych4X12wWieCaFbSEbwZRxmjRTMgbm7RDybYTpD"]))
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("QRKqHqP5SNEngXrcK2QeAR2nqx9AmwbHrmYF49ZbkEK")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableData(approverPublicKey: "7AH35qStXtrUgRkmqDmhjufNHjF74R1A9cCKT3C3HaAR").toHexString(),
            "0201040869ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c7155b867b0ff902f8bd3503e7a6c3ba5a94b90bd26858f6de78aa0913af0d8be7c6fc178caf216681e7b5d744beeca4c54681c9df12ffbd88f3bb1629ec0d56475211fa69aa5bb02ddd4a80e4673e541767116f2034406d2f917725045d215bdd3f06a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b21000000000000000000000000000000000000000000000000000000000000000000000000095f6d73715ba2affc6e25f8845e8f18908d92a129f233413b34d675d6fbd03d05ffdcd59d8f12aab0f8644eb0a57db2187baf6cc1e0115a977082f2ecd54120020603020400040400000007030301052209010aba765b69604b25cb6cca94eb09179fb0c181d1ead2e25d4430fd8c52e89419"
        )
    }
    
    func testBitcoinWalletCreationApprovalDisposition() throws {
        let request = getApprovalRequest(getBitcoinWalletCreationRequest())
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [],
            email: "dont care"
        )
        
        let signableData = try approvalRequest.signableData(approverPublicKey: "7AH35qStXtrUgRkmqDmhjufNHjF74R1A9cCKT3C3HaAR")
        
        XCTAssertEqual(
            try JSONDecoder().decode(SolanaApprovalRequestType.self, from: signableData),
            approvalRequest.requestType
        )
    }
    
    func testEthereumWalletCreationApprovalDisposition() throws {
        let request = getApprovalRequest(getEthereumWalletCreationRequest())
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [],
            email: "dont care"
        )
        
        let signableData = try approvalRequest.signableData(approverPublicKey: "7AH35qStXtrUgRkmqDmhjufNHjF74R1A9cCKT3C3HaAR")
        
        XCTAssertEqual(
            try JSONDecoder().decode(SolanaApprovalRequestType.self, from: signableData),
            approvalRequest.requestType
        )
    }
    
    func testWalletCreationInitiationRequest() throws {
        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(),
            initiatorIsApprover: true
        )
        let requestType: SolanaApprovalRequestType = getSolanaWalletCreationRequest(nonceAccountAddresses: ["CL8fZq5BzjCBXmixSMKqBsFoCLSFxqN6GvheDQ68HP44"])
        let request = getWalletInitiationRequest(requestType, initiation: initiation)
        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "2d7db52f8ff35aec03cd7be8d26c45d798774a4d5dfa9a9c559778752fb87d11".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: [CensoApi.Nonce("QRKqHqP5SNEngXrcK2QeAR2nqx9AmwbHrmYF49ZbkEK")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ").toHexString(),
            "0301040969ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c71511fa69aa5bb02ddd4a80e4673e541767116f2034406d2f917725045d215bdd3f2ba22d14fd3198775d3b9d1b22d6b48743f502ac2129cdf0094af144febf0666a8574221c4298fd6dd12f8d67ac57a7e3586087ff177defef319a8f2b7ae8a99ff90e321f14ded704cbb267d1cbd7c0e9ae8c5e3ccbb6f47c95bbf75d5a924a606a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b21000000000000000000000000000000000000000000000000000000000000000000000000095f6d73715ba2affc6e25f8845e8f18908d92a129f233413b34d675d6fbd03d05ffdcd59d8f12aab0f8644eb0a57db2187baf6cc1e0115a977082f2ecd54120030703030500040400000007020001340000000080b2720000000000b803000000000000095f6d73715ba2affc6e25f8845e8f18908d92a129f233413b34d675d6fbd03d080501040206009901030000000000000000000000000000000000000000000000000000000000000000000000000000000000b59460e652df36f1ffb509cdf44bb3469f9054f93f8f707fe56685cdc6fc9c3300b94e0c79c1fb7db6ff3380f8bd8f09376fb8f87c488f98ec920164e1e3a7417101100e0000000000000100b33db8d45a74ca5c0593ea113efc73528320af0a70713d08f1ec3fa085c9c74c000001"
        )
    }
    
    func testSolWithdrawalRequestApprovalDisposition() throws {
        let request = getApprovalRequest(getSolWithdrawalRequest(nonceAccountAddresses: ["AaFj4THN8CJmDPyJjPuDpsfC5FZys2Wmczust5UfmqeN"]))
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("9PGftXH39kRKndTxL4hQppfonLMZQpWWWzvaHzYsAcLy")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableData(approverPublicKey: "8CpMnz9RNojAZWMyzWirH3Y7vBebkf2965SGmcwgYSY").toHexString(),
            "0201040869ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c71501d86d390e73db0061cc718bad82036d774f115923c2e5e6c675ca99dd41c4fd8e3dffb3877aaf1f737715f58920c52f4fcec66fab4ac69bb95f0ad69e33bcd77c4c8d158b8f7d6a29a29e8f938db7344b356d823531737b5405d71c995eab1a06a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b21000000000000000000000000000000000000000000000000000000000000000000000000095f6d73715ba2affc6e25f8845e8f18908d92a129f233413b34d675d6fbd03d7c91fdec5cfa84288fc1e5d1732f0cc5ebba8ba90e1720fc85cf8f328bd1529a0206030204000404000000070303010522090132577d9ee7c270f02040c9da6af65a135da4b69c5d57bebdb52e245ecc0f16d8"
        )
    }

    func testSolWithdrawalRequestInitiationRequest() throws {
        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(),
            initiatorIsApprover: true
        )
        let requestType: SolanaApprovalRequestType = getSolWithdrawalRequest(nonceAccountAddresses: ["CL8fZq5BzjCBXmixSMKqBsFoCLSFxqN6GvheDQ68HP44"])
        let request = getWalletInitiationRequest(requestType, initiation: initiation)
        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "7de2dc4f438213a502317cc43a58cbe4a23e8680a2438e9166334393effd726f".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: [CensoApi.Nonce("4LTSSabuoUArWeLyAS2nstT4EjmP8L3y8qXYgJqRs6RC")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ").toHexString(),
            "0301080e69ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c715f6e8d816af808b1e4407ef06675d067e201881fc785606e3a12eec7c8bccb0712ba22d14fd3198775d3b9d1b22d6b48743f502ac2129cdf0094af144febf0666a8574221c4298fd6dd12f8d67ac57a7e3586087ff177defef319a8f2b7ae8a99ff90e321f14ded704cbb267d1cbd7c0e9ae8c5e3ccbb6f47c95bbf75d5a924a60be476bc2de9162c6f52a1170d16d263bd60cca5c76b924b8b94690e4c22a10f06a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea94000001209c6930f6cb4d8e110eb62f6f9133ec338123ab6822970d5c055e0e0adc33b06a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b2100000000000000000000000000000000000000000000000000000000000000000000000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a906a7d517192c5c51218cc94c3d4af17f58daee089ba1fd44e3dbd98a000000008c97258f4e2489f1bb3d1029148e0d830b5a1399daff1084048e7bd8dbe9f859095f6d73715ba2affc6e25f8845e8f18908d92a129f233413b34d675d6fbd03d318efd8bd8dbc9ddab3329f58c5b16054ef3506a1c7c284eb6a13411a94f913f030903030600040400000009020001340000000080b2720000000000b803000000000000095f6d73715ba2affc6e25f8845e8f18908d92a129f233413b34d675d6fbd03d0d0d010405070208000909090a0b0c72070000000000000000000000000000000000000000000000000000000000000000000000000000000000b59460e652df36f1ffb509cdf44bb3469f9054f93f8f707fe56685cdc6fc9c330065cd1d00000000cd62deaa07b0058a44cc8ec7b3a5fc67156a8b6d82bb4223b58d554a624256be"
        )
    }


    func testSplWithdrawalRequestApprovalDisposition() throws {
        let request = getApprovalRequest(getSplWithdrawalRequest(nonceAccountAddresses: ["AaFj4THN8CJmDPyJjPuDpsfC5FZys2Wmczust5UfmqeN"]))
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("9PGftXH39kRKndTxL4hQppfonLMZQpWWWzvaHzYsAcLy")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableData(approverPublicKey: "8CpMnz9RNojAZWMyzWirH3Y7vBebkf2965SGmcwgYSY").toHexString(),
            "02010408d5259a75898e5c16f1b0675c496a9f8ee74dd7687f234ba93c0ff09dfee8af3401d86d390e73db0061cc718bad82036d774f115923c2e5e6c675ca99dd41c4fd8e3dffb3877aaf1f737715f58920c52f4fcec66fab4ac69bb95f0ad69e33bcd7515cf7a3ae636d0b1f0ac3f76dc5bafdf519e49df160e0d2f5eb77747a40f23006a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b210000000000000000000000000000000000000000000000000000000000000000000000000ec4916daf26706bf27b89ecfff6ba56155f1d4ab734f92f008b81d4176076267c91fdec5cfa84288fc1e5d1732f0cc5ebba8ba90e1720fc85cf8f328bd1529a02060302040004040000000703030105220901f5b64c094158e4d4b31dfc38b6c2b28b458a5d9fe0c33f1cb3736318f77f5a52"
        )
    }

    func testSplWithdrawalRequestInitiationRequest() throws {
        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(),
            initiatorIsApprover: true
        )
        let requestType: SolanaApprovalRequestType = getSplWithdrawalRequest(nonceAccountAddresses: ["6UcFAr9rqGfFEtLxnYdW6QjeRor3aej5akLpYpXUkPWX"])
        let request = getWalletInitiationRequest(requestType, initiation: initiation)
        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "4ba2d7074c6fa66dca792b64260b0513a229fa0849b1ceaa5b9cff1285fedee7".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: [CensoApi.Nonce("9kV51VcoGhA1YFkBxBhd7rG1nz7ZCVcsBpqaaGa1hgCD")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "AbmwBa52qPj5zpWQxeJJ3ZSDRDxnyZMWitrE8nd4mrmi").toHexString(),
            "03010910d5259a75898e5c16f1b0675c496a9f8ee74dd7687f234ba93c0ff09dfee8af34e34e9cdb62a817da76d5163666c93570c210e7287f7f268c77236b3002156ca08ea1bcb15aa292a9b51b7f05f19d0e27669957b9990a4aa8f9cddc1cf4c56c55515cf7a3ae636d0b1f0ac3f76dc5bafdf519e49df160e0d2f5eb77747a40f230631f065d4a6b93340e8b8a8c3061fd6eb0b7d402fe560fc40a84e9c8ce1ac303f46cdc8655b9add6c8905bd1247a2ef15870d4076fb39915885d08628a9f22a493c4b438027247811fa84db55c2e6ede640264dad0876d56a8bf819f2cb17bfa06a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea94000005c66b35c237860fd27d95409d452edbd91300bbfe80850fd4841759722b5073106a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b21000000008df1a38eac809d9806f4e9502bc085aadb4975b84dc3ba062b1ce416efd4b1c5000000000000000000000000000000000000000000000000000000000000000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a906a7d517192c5c51218cc94c3d4af17f58daee089ba1fd44e3dbd98a000000008c97258f4e2489f1bb3d1029148e0d830b5a1399daff1084048e7bd8dbe9f8590ec4916daf26706bf27b89ecfff6ba56155f1d4ab734f92f008b81d4176076268201354297cec572707724dac5f6c92613c5a8f04e34fe284c882de8d09a0826030b0303070004040000000b020001340000000080b2720000000000b8030000000000000ec4916daf26706bf27b89ecfff6ba56155f1d4ab734f92f008b81d4176076260f0d010405080209000a060b0c0d0e72070000000000000000000000000000000000000000000000000000000000000000000000000000000000c381ac8c68089013328ad37eda42b285abedc13fef404fc34e56528011ded600f401000000000000f7d1a2ef642101c041a4523de1dd26652402149065ae308c55e1924cb217cb48"
        )
    }

    func testUSDCconversionRequestApprovalDisposition() throws {
        let request = getApprovalRequest(getConversionRequest(nonceAccountAddresses: ["6UcFAr9rqGfFEtLxnYdW6QjeRor3aej5akLpYpXUkPWX"]))
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("9kV51VcoGhA1YFkBxBhd7rG1nz7ZCVcsBpqaaGa1hgCD")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableData(approverPublicKey: "6bpAbKqWrtXBtdnWqA8YSybGTeyD91u9MNzQuP7641MH").toHexString(),
            "02010307d2c2e3ac53223ce6b5a6e04fe0f98071cf10a62646b6c1c100f9829afcced04e5335831f99da167bf80d87be098dbaafc9309035be4aedd53460c3571c05b6a0515cf7a3ae636d0b1f0ac3f76dc5bafdf519e49df160e0d2f5eb77747a40f230000000000000000000000000000000000000000000000000000000000000000006a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b2100000000a78bdd1907176367f56f7fab4bee90dabaa7372794fb0403f75f2a96580998478201354297cec572707724dac5f6c92613c5a8f04e34fe284c882de8d09a082602030302040004040000000603030105220901db20e8ec87e412a88078e810a7dda408df916bd03f429a92a6d3b00fd819e304"
        )
    }

    func testUSDCConversionRequestInitiationRequest() throws {
        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(),
            initiatorIsApprover: true
        )
        let requestType: SolanaApprovalRequestType = getConversionRequest(nonceAccountAddresses: ["6UcFAr9rqGfFEtLxnYdW6QjeRor3aej5akLpYpXUkPWX"])
        let request = getWalletInitiationRequest(requestType, initiation: initiation)
        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "5f27be66e3eb697a4274f9359c87f9069762a5e2cb7a63a622e923bd6119b963".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: [CensoApi.Nonce("9kV51VcoGhA1YFkBxBhd7rG1nz7ZCVcsBpqaaGa1hgCD")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "6bpAbKqWrtXBtdnWqA8YSybGTeyD91u9MNzQuP7641MH").toHexString(),
            "03010910d2c2e3ac53223ce6b5a6e04fe0f98071cf10a62646b6c1c100f9829afcced04e17ce130f4d1b123ff7f5f840aee4e9fa5665106de0cf2d1245c2b60f6ade6e245335831f99da167bf80d87be098dbaafc9309035be4aedd53460c3571c05b6a0515cf7a3ae636d0b1f0ac3f76dc5bafdf519e49df160e0d2f5eb77747a40f2301bbc7e99fc43d0c442a698780fa1c7e4bcfbe5f100df263390ef0ab695e1b85ad1e5bffc491a1b7890805d162a2cf8f0a2facae1df8579eddfed575e44f958108e829493f87ba7dc9497154a2cf8e656ee9979277f9ac88b5570775e7cb447d106a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea9400000a1a993efade361c637af59e4d387db1aec381df43083f38e789f4bd57280889906a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b21000000008ac94d970e27bc29711d382b1d5fac3fe82f590485b065e57fcc6e83424110cd000000000000000000000000000000000000000000000000000000000000000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a906a7d517192c5c51218cc94c3d4af17f58daee089ba1fd44e3dbd98a000000008c97258f4e2489f1bb3d1029148e0d830b5a1399daff1084048e7bd8dbe9f859a78bdd1907176367f56f7fab4bee90dabaa7372794fb0403f75f2a96580998478201354297cec572707724dac5f6c92613c5a8f04e34fe284c882de8d09a0826030b0303070004040000000b020001340000000080b2720000000000b803000000000000a78bdd1907176367f56f7fab4bee90dabaa7372794fb0403f75f2a96580998470f0d010405080209000a060b0c0d0e72070000000000000000000000000000000000000000000000000000000000000000000000000000000000138543b25e89429dae0ec18a0fa198dc5006898f91b3b99d80a58d65bcdff9d00065cd1d00000000455c311d68d6d25a36bb09d58c4f62e6e637031c29b7fd3bd205b658500739cf"
        )
    }

    func testWrapConversionRequestInitiationRequest() throws {
        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(),
            initiatorIsApprover: true
        )
        let requestType: SolanaApprovalRequestType = getWrapConversionRequest(nonceAccountAddresses: ["2vztVvZ75DahxgQVokC41yGyuiGNVaYiq7SvbiuJvjPn"])
        let request = getWalletInitiationRequest(requestType, initiation: initiation)

        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation:                                                           "2aebddceb0b8bc6fd1de488581f3dc2a8885c10cdeb8558ee1ad61376ac4559a".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: [CensoApi.Nonce("5HprjcSDd6j66giEixqAjnpaTUbBBqSd2qTRzerKip6Q")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "ECiEjQXPJ792V4Vrs7gozNrGVVshtxN9o9q9RDTqPSeK").toHexString(),
            "0301080f69ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c715d0d33af1c6176bb01ba49b14e689a1d41cf0ccd26ed491c364fe4f5c85eea36ac427f20ac9355c07889792ca5b3c6209b1da8ca6493791cf09b342e9ccd894a81cb0ec82ff31aaf4d9543dea49f81a7fcb3fa6580bc496931ecce2ecfedce62937e6b667543711a51d985aacd1977b573bf5834059ab61c0d7a49e850f941bf5e4ebbc956e56d364d65a07ff43758c7ee8f2e963f2e3dfd3dc9cd15ff842e6b1f21e972fd1a819f52b4c7bba8945c0cdb1ef51798ef5ec44c8c2c06f95a831cc06a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea9400000069b8857feab8184fb687f634618c035dac439dc1aeb3b5598a0f0000000000106a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b2100000000000000000000000000000000000000000000000000000000000000000000000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a906a7d517192c5c51218cc94c3d4af17f58daee089ba1fd44e3dbd98a000000008c97258f4e2489f1bb3d1029148e0d830b5a1399daff1084048e7bd8dbe9f8596ef843384c5930efbf1d8582474f8222be9ccb098382243997545b0934f614043fbe273e247a8f6f42216cda9b27c264dab85b8d381f95307c5e644746f6abbd030a0303070004040000000a020001340000000080b2720000000000b8030000000000006ef843384c5930efbf1d8582474f8222be9ccb098382243997545b0934f614040e0c01040506080209000a0b0c0d530a00000000000000000000000000000000000000000000000000000000000000000000000000000000005116fa6eadd22db290714aff1833149e82fcc5f8ae151880a260d3a40872455d0065cd1d0000000000"
        )
    }
    
    func testUnwrapConversionRequestInitiationRequest() throws {
        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(),
            initiatorIsApprover: true
        )
        let requestType: SolanaApprovalRequestType = getUnwrapConversionRequest(nonceAccountAddresses: ["C2Fo1L8qFzmfucaVpLxVt7sYdUEorHYiYfNS2iPGXhxP"])
        let request = getWalletInitiationRequest(requestType, initiation: initiation)
        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "1f00703a5a544f81174fc90ddee2c11a1d43d5011c363a8f943b2adabc78ca52".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: [CensoApi.Nonce("3sW5nKBjmPkCtaXcBQperkPbjjq1zh55WBYzqtn9snjP")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "3S3WAHv5h7gyEVTPQRuz6sf8poKM439zr14pHF43MtLK").toHexString(),
            "0301081069ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c71559dd5a48b688d5903bf3567f05edf0ca12745f9146356f9256033dae9a31cc4a2421b9558d9cad67bd5659f0331b3fde0d92a4c499163a4c2ccc11270a2d1d2ca3c2dd1d18d8e3fc1fa348bbf55e69e9e8a08ce9d200c25d75a4f249959f504cf620464ffe688ce6d211cd6634828308f9ee848ee9c65e9b447f6cc110bcb1f36275d74f500d64b47ff8dc6c9bfb82e3719880e03108b80f16d99216a7cab105691ced267cd43434095fd9cca6f91dfc377cd32477982218304ddbfb22f80dd4ef0bb334bbe5de40c74a349008b2e63384f665fc8b7fe3f5e78f72763a49127706a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea9400000069b8857feab8184fb687f634618c035dac439dc1aeb3b5598a0f0000000000106a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b2100000000000000000000000000000000000000000000000000000000000000000000000006ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a906a7d517192c5c51218cc94c3d4af17f58daee089ba1fd44e3dbd98a000000008c97258f4e2489f1bb3d1029148e0d830b5a1399daff1084048e7bd8dbe9f85901e7592836b04fb733c4ba26fba673c11822b869e3d71275da54051523c747c72aa74c4491bcecb2fb4e5c9deb5e9e12aa1286114d50d7fcbd1948e10cb2701e030b0303080004040000000b020001340000000080b2720000000000b80300000000000001e7592836b04fb733c4ba26fba673c11822b869e3d71275da54051523c747c70f0e0104050609020a00070b0c0d0e05530af01d1f00000000000139ed553bc39b91b4368c79f3383ead20640d917fec1312697463a4b062b8ed5539ed553bc39b91b4368c79f3383ead20640d917fec1312697463a4b062b8ed5500a3e1110000000001"
        )
    }

    func testDAppTransactionRequestInitiationRequest() throws {
        let opAccountPk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "d2f0127d8f2bb32b6a97d63c0e60a726eb56a8f70aca03c6dd18da622329b885".data(using: .hexadecimal)!)

        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(accountSize: 3649, minBalanceForRentExemption: 26287920),
            initiatorIsApprover: true
        )

        let nonceAccountAddresses = ["35A9HBB3Vx23WdEfmxhTRYkgj18naQF6UHFsh7zcLtN5", "8d8KzYs6d1mcQfiiHW2s1vHyt5DpB9ihQZVe87XZoEgs", "9zD4StAoTY1BGeNyCz37BPHqgDbhTZ7ZBNRrHw62yVaD"]
        let nonces = [
            CensoApi.Nonce("5NW3hU46wJZWyLoLciNH1n5xhuudK5i4aU2Q7BqBf4yb"),
            CensoApi.Nonce("HA1WYX1kJowLys8Fdyqj4qaYQNaQjtMtNcW7xiExdY5U"),
            CensoApi.Nonce("5NW3hU46wJZWyLoLciNH1n5xhuudK5i4aU2Q7BqBf4yb")
        ]

        let requestType: SolanaApprovalRequestType = getDAppTransactionRequest(nonceAccountAddresses: nonceAccountAddresses)
        let request = getWalletInitiationRequest(requestType, initiation: initiation)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: nonces,
            email: "dont care",
            opAccountPrivateKey: opAccountPk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "6f51NkToPKgK2AY6GGf7scdbwXpZGNmkx6wvCdp9rQPW").toHexString(),
            "0301040969ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c7159453ec424f5b12ea3fd1d4484473b64addd2fd39b3bf61ca51791b8c7ed4b125540b09169e97b369c32ef1e1927b5921d3ff3428936144281eee569cc892d75d1ec808e9cb64eb5f7ece18294bf13facea925070f3a572e82e233429a6d23d3aeb95c173167bb491df8390ce739d4280d7753129cb16ba4e40cbaf9c55ddd71506a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b2100000000000000000000000000000000000000000000000000000000000000000000000042d00bf5d95ce802a60666271deaaf893af537b5cefbeb024b7fe29f8a98d89340f0c9a62c05ec5d2c69efdc27ad6c03c2daf658511b6b3d6bc7ed170910d94e0307030305000404000000070200013400000000301f910100000000410e00000000000042d00bf5d95ce802a60666271deaaf893af537b5cefbeb024b7fe29f8a98d893080501040206008c011000000000000000000000000000000000000000000000000000000000000000000000000000000000009b01d146e8623bc026278e8fba96395d7ce791a99a023026701000c097db0965ee21410f0680db8c239659e2c6ad45576e5d44fb94576640202b542bbc6b14282e90c13b0d471b592c2984568133a41676460f72c885db57ad26bd5b628f93829003"
        )

        let supplyInstructions = try initiationRequest.supplyInstructions
        XCTAssertEqual(supplyInstructions.count, 2)
        XCTAssertEqual(supplyInstructions[0].nonce, nonces[1])
        XCTAssertEqual(supplyInstructions[0].nonceAccountAddress, nonceAccountAddresses[1])
        try XCTAssertEqual(
            supplyInstructions[0].signableData(approverPublicKey: "6f51NkToPKgK2AY6GGf7scdbwXpZGNmkx6wvCdp9rQPW").toHexString(),
            "0201040869ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c715540b09169e97b369c32ef1e1927b5921d3ff3428936144281eee569cc892d75d714300b6b43d494f7bac3552b1736fe9bdf5ea3a2b09f7d5213fbb838613f5cc9453ec424f5b12ea3fd1d4484473b64addd2fd39b3bf61ca51791b8c7ed4b12506a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea9400000eb95c173167bb491df8390ce739d4280d7753129cb16ba4e40cbaf9c55ddd715000000000000000000000000000000000000000000000000000000000000000042d00bf5d95ce802a60666271deaaf893af537b5cefbeb024b7fe29f8a98d893f009cb46c7036733270ded2da31806eceeb75296fd4ba95ff292290976212b4f0206030204000404000000070303050199061c0000140300000000000000000000000000000000000000000000000000000000000000000200031f6d7afd3ddd3877da31b9f7c54447d20036e74483c4a559fa57c7e3dabadd98019ae013b70eb0f3e8bc97cd7c9d1eb156876f89ffd6653c575e8ae1dbc95f0fdd0c000200000000c2eb0b000000000000000000000000000000000000000000000000000000000000000000000000020003bd0c59f3c8b32c4666e0587e89487d345061c3b7a6d4d787366a6172e373ada6019ae013b70eb0f3e8bc97cd7c9d1eb156876f89ffd6653c575e8ae1dbc95f0fdd0c000200000000c2eb0b000000000000000000000000000000000000000000000000000000000000000000000000020003244aa347674add72ce29ee55e245317999d71dcb66b960a4fa8faf81cce1ad85019ae013b70eb0f3e8bc97cd7c9d1eb156876f89ffd6653c575e8ae1dbc95f0fdd0c000200000000c2eb0b0000000000000000000000000000000000000000000000000000000000000000000000000200032fe927b08c1f41a7f480c250f70e9deb5679d9aa194015f064f1834ea664a66e019ae013b70eb0f3e8bc97cd7c9d1eb156876f89ffd6653c575e8ae1dbc95f0fdd0c000200000000c2eb0b0000000000000000000000000000000000000000000000000000000000000000000000000200036c057fa62da2dab96d5b019fb35ede59f3f5d8ede867e6b6bc7fa5cabaea26b0019ae013b70eb0f3e8bc97cd7c9d1eb156876f89ffd6653c575e8ae1dbc95f0fdd0c000200000000c2eb0b0000000000000000000000000000000000000000000000000000000000000000000000000200033c49df4d376ffe13dd130ad72f047e26d751132dd20d77efad76359461959423019ae013b70eb0f3e8bc97cd7c9d1eb156876f89ffd6653c575e8ae1dbc95f0fdd0c000200000000c2eb0b0000000000000000000000000000000000000000000000000000000000000000000000000200033a0dae726ee6a30812a205bf398101873c21d992d90e2586704fe0501e6e4de7019ae013b70eb0f3e8bc97cd7c9d1eb156876f89ffd6653c575e8ae1dbc95f0fdd0c000200"
        )
        
        XCTAssertEqual(supplyInstructions[1].nonce, nonces[2])
        XCTAssertEqual(supplyInstructions[1].nonceAccountAddress, nonceAccountAddresses[2])
        try XCTAssertEqual(
            supplyInstructions[1].signableData(approverPublicKey: "6f51NkToPKgK2AY6GGf7scdbwXpZGNmkx6wvCdp9rQPW").toHexString(),
            "0201040869ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c715540b09169e97b369c32ef1e1927b5921d3ff3428936144281eee569cc892d75d85853cb639746b6acadb9b0b04f5691f8acfeb7eb072d9e1d5cbe32258b4a7e69453ec424f5b12ea3fd1d4484473b64addd2fd39b3bf61ca51791b8c7ed4b12506a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea9400000eb95c173167bb491df8390ce739d4280d7753129cb16ba4e40cbaf9c55ddd715000000000000000000000000000000000000000000000000000000000000000042d00bf5d95ce802a60666271deaaf893af537b5cefbeb024b7fe29f8a98d89340f0c9a62c05ec5d2c69efdc27ad6c03c2daf658511b6b3d6bc7ed170910d94e0206030204000404000000070303050181011c14037c00000000c2eb0b0000000000000000000000000000000000000000000000000000000000000000000000000200033dad09a2add0da31eae887959f34baa1c96dd62c591e523b04aa29caf762f16c019ae013b70eb0f3e8bc97cd7c9d1eb156876f89ffd6653c575e8ae1dbc95f0fdd0c000200000000c2eb0b00000000"
        )
    }

    func testDAppTransactionRequestApprovalDisposition() throws {
        let request = getApprovalRequest(getDAppTransactionRequest(nonceAccountAddresses: ["7mKUZ5BjRu1bwbhFWNfhntaXnT1L1H7XNDfCi3Bc9zYf"]))
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("6YQSbuqgWffeQ3UBg3ni7Xq865Zx6VzY38aru3RUGY4g")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableData(approverPublicKey: "9vgBZg7RPtcwkMLrs2VSDeWQjfbyChy1SLbiWhRxod5U").toHexString(),
            "0201040869ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c715849d94e7ea12e11fec2d8674fb52ecf06f3b37e368e9916b67590b9a6f56de336480912493d74468dff6ca3393e3e7344ddc2d48471cde470089f7ac92cfc0e09453ec424f5b12ea3fd1d4484473b64addd2fd39b3bf61ca51791b8c7ed4b12506a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b2100000000000000000000000000000000000000000000000000000000000000000000000042d00bf5d95ce802a60666271deaaf893af537b5cefbeb024b7fe29f8a98d8935255f1ebaeeb237e1d7d8ad8679ca5f72f8875e6df970131989296f9d79eddb902060302040004040000000703030105220901d17d770dab012a12e62c63b198da8573be123b8447e8bb4f6dbe912dda42d0a1"
        )
    }

    func testAddDAppBookEntryApprovalRequest() throws {
        let request = getApprovalRequest(getAddDAppBookEntry(nonceAccountAddresses: ["AaFj4THN8CJmDPyJjPuDpsfC5FZys2Wmczust5UfmqeN"]))
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("9PGftXH39kRKndTxL4hQppfonLMZQpWWWzvaHzYsAcLy")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableData(approverPublicKey: "ErWAApTUwunKAobwFrVe2fTwtqdsQecQqWKSQJzysg4z").toHexString(),
            "02010408d5259a75898e5c16f1b0675c496a9f8ee74dd7687f234ba93c0ff09dfee8af34cdd65bdd5302de9e0457368e03c37dcd1e9029c3ab0facdcfc5889a81d0cf6138e3dffb3877aaf1f737715f58920c52f4fcec66fab4ac69bb95f0ad69e33bcd7f9437a782883b62d38738b3da7fada188510e6d57d1e09bdbde19cf7ed16e60206a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b210000000000000000000000000000000000000000000000000000000000000000000000002345d893870173ce1252d056dbc6c8bf6bb01f157832734623958d6249e63b5c7c91fdec5cfa84288fc1e5d1732f0cc5ebba8ba90e1720fc85cf8f328bd1529a02060302040004040000000703030105220901d0225d0606ab4392c16c7be80cbf674e9424767c3c9acdb8ae1661470c4ddb65"
        )
    }

    func testAddDAppBookEntryInitiationRequest() throws {
        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(),
            initiatorIsApprover: true
        )
        let requestType: SolanaApprovalRequestType = getAddDAppBookEntry(nonceAccountAddresses: ["AaFj4THN8CJmDPyJjPuDpsfC5FZys2Wmczust5UfmqeN"])
        let request = getWalletInitiationRequest(requestType, initiation: initiation)
        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "72ff8f7fb4a441c93d4003e2bf67dd367e3293311c4f9433c422a2fbf305c477".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: [CensoApi.Nonce("9PGftXH39kRKndTxL4hQppfonLMZQpWWWzvaHzYsAcLy")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "BEzpSizrNZpCeLWTk23nozu4T4wEzxoDJGoUUYBBhVbE").toHexString(),
            "03010409d5259a75898e5c16f1b0675c496a9f8ee74dd7687f234ba93c0ff09dfee8af34f9437a782883b62d38738b3da7fada188510e6d57d1e09bdbde19cf7ed16e602982acb779028b0afdd5da5a26d78e1b82804ae449ce2fd2767d15f4325a7f1118e3dffb3877aaf1f737715f58920c52f4fcec66fab4ac69bb95f0ad69e33bcd7064fd89d243e47f6bd6ea9c7462d7ca1d504c02bf67d2b6738f892897ecaeab206a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b210000000000000000000000000000000000000000000000000000000000000000000000002345d893870173ce1252d056dbc6c8bf6bb01f157832734623958d6249e63b5c7c91fdec5cfa84288fc1e5d1732f0cc5ebba8ba90e1720fc85cf8f328bd1529a030703030500040400000007020001340000000080b2720000000000b8030000000000002345d893870173ce1252d056dbc6c8bf6bb01f157832734623958d6249e63b5c080501040206006d1400000000000000000000000000000000000000000000000000000000000000000000000000000000000100e4523ff383e6bb5f73d3745e3554f53a56c61ba17c7bc49e481a9d01a96fdbd6a9037bac86a669c3470c8da04dcec8f3a3ec671cd157264078954f38c387efb000"
        )
    }

    func testRemoveDAppBookEntryApprovalRequest() throws {
        let request = getApprovalRequest(getRemoveDAppBookEntry(nonceAccountAddresses: ["AaFj4THN8CJmDPyJjPuDpsfC5FZys2Wmczust5UfmqeN"]))
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("9PGftXH39kRKndTxL4hQppfonLMZQpWWWzvaHzYsAcLy")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableData(approverPublicKey: "ErWAApTUwunKAobwFrVe2fTwtqdsQecQqWKSQJzysg4z").toHexString(),
            "02010408d5259a75898e5c16f1b0675c496a9f8ee74dd7687f234ba93c0ff09dfee8af34cdd65bdd5302de9e0457368e03c37dcd1e9029c3ab0facdcfc5889a81d0cf6138e3dffb3877aaf1f737715f58920c52f4fcec66fab4ac69bb95f0ad69e33bcd779dac0b298597dcbf810eb17709c9a75e1f4e569efe90f323c91c4ef084882c206a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b210000000000000000000000000000000000000000000000000000000000000000000000002345d893870173ce1252d056dbc6c8bf6bb01f157832734623958d6249e63b5c7c91fdec5cfa84288fc1e5d1732f0cc5ebba8ba90e1720fc85cf8f328bd1529a020603020400040400000007030301052209019268d8dd8d58ab95cf2d7f3ed9312dfbc131310a3068c8affa3b6518a359c85c"
        )
    }

    func testRemoveDAppBookEntryInitiationRequest() throws {
        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(),
            initiatorIsApprover: true
        )
        let requestType: SolanaApprovalRequestType = getRemoveDAppBookEntry(nonceAccountAddresses: ["AaFj4THN8CJmDPyJjPuDpsfC5FZys2Wmczust5UfmqeN"])
        let request = getWalletInitiationRequest(requestType, initiation: initiation)
        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "1d3462075eae5a46257981c00c20982dd27a88b70a88ff95455dad6bc88859aa".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: [CensoApi.Nonce("9PGftXH39kRKndTxL4hQppfonLMZQpWWWzvaHzYsAcLy")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "BEzpSizrNZpCeLWTk23nozu4T4wEzxoDJGoUUYBBhVbE").toHexString(),
            "03010409d5259a75898e5c16f1b0675c496a9f8ee74dd7687f234ba93c0ff09dfee8af3479dac0b298597dcbf810eb17709c9a75e1f4e569efe90f323c91c4ef084882c2982acb779028b0afdd5da5a26d78e1b82804ae449ce2fd2767d15f4325a7f1118e3dffb3877aaf1f737715f58920c52f4fcec66fab4ac69bb95f0ad69e33bcd7064fd89d243e47f6bd6ea9c7462d7ca1d504c02bf67d2b6738f892897ecaeab206a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b210000000000000000000000000000000000000000000000000000000000000000000000002345d893870173ce1252d056dbc6c8bf6bb01f157832734623958d6249e63b5c7c91fdec5cfa84288fc1e5d1732f0cc5ebba8ba90e1720fc85cf8f328bd1529a030703030500040400000007020001340000000080b2720000000000b8030000000000002345d893870173ce1252d056dbc6c8bf6bb01f157832734623958d6249e63b5c080501040206006d140000000000000000000000000000000000000000000000000000000000000000000000000000000000000100e4523ff383e6bb5f73d3745e3554f53a56c61ba17c7bc49e481a9d01a96fdbd6a9037bac86a669c3470c8da04dcec8f3a3ec671cd157264078954f38c387efb0"
        )
    }

    func testAddAddressBookEntryInitiationRequest() throws {
        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(),
            initiatorIsApprover: true
       )
        let requestType: SolanaApprovalRequestType = getAddAddressBookEntry(nonceAccountAddresses: ["8R4EuFv5f31D8HijRXA4eyebKMZ287ho2UyPpbtQ8Gos"])
        let request = getWalletInitiationRequest(requestType, initiation: initiation)
        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "a37195e87d53a831c1947e8afe02aec367e78f62fb912f7a614c3a387cd911fa".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: [CensoApi.Nonce("7r8cdEASTnapMjhk569Kwq7mtWwaqjMmkxYe75PBCCK5")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ").toHexString(),
            "0301040969ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c715be9052f2d7dc89487f3ec139a60d9cdda96f0d21895effdc81fc6906936345442ba22d14fd3198775d3b9d1b22d6b48743f502ac2129cdf0094af144febf06666e2b693808b4e0103f5b69faec8d19b9b92d12819052c214855f50e7dd3d1e22ff90e321f14ded704cbb267d1cbd7c0e9ae8c5e3ccbb6f47c95bbf75d5a924a606a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b21000000000000000000000000000000000000000000000000000000000000000000000000095f6d73715ba2affc6e25f8845e8f18908d92a129f233413b34d675d6fbd03d65bc30ccd8e88f4b8d5cf5903523b520f1cf0dea124d428b55038269c03609bc030703030500040400000007020001340000000080b2720000000000b803000000000000095f6d73715ba2affc6e25f8845e8f18908d92a129f233413b34d675d6fbd03d080501040206006e16000000000000000000000000000000000000000000000000000000000000000000000000000000000001001209c6930f6cb4d8e110eb62f6f9133ec338123ab6822970d5c055e0e0adc33bcd62deaa07b0058a44cc8ec7b3a5fc67156a8b6d82bb4223b58d554a624256be0000"
        )
    }
    
    func testAddAddressBookEntryApprovalRequest() throws {
        let request = getApprovalRequest(getAddAddressBookEntry(nonceAccountAddresses: ["Aj8MqPBaM8fSbgJiUtq2PXESGTSQPsgHqJ13JyzQZCRZ"]))
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("7r8cdEASTnapMjhk569Kwq7mtWwaqjMmkxYe75PBCCK5")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableData(approverPublicKey: "7AH35qStXtrUgRkmqDmhjufNHjF74R1A9cCKT3C3HaAR").toHexString(),
            "0201040869ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c7155b867b0ff902f8bd3503e7a6c3ba5a94b90bd26858f6de78aa0913af0d8be7c69083e5bc3e157aff14eb7d4db4331ce36f0b43c131c269bbe16f79ab36f98eacbe9052f2d7dc89487f3ec139a60d9cdda96f0d21895effdc81fc69069363454406a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b21000000000000000000000000000000000000000000000000000000000000000000000000095f6d73715ba2affc6e25f8845e8f18908d92a129f233413b34d675d6fbd03d65bc30ccd8e88f4b8d5cf5903523b520f1cf0dea124d428b55038269c03609bc0206030204000404000000070303010522090116aa15d9a45731f7335bdda8a6ffb737d81fa305362c38ff4e9a8495bea126c9"
        )
    }
    

    func testWalletConfigPolicyUpdateApprovalRequest() throws {
        let request = getApprovalRequest(getWalletConfigPolicyUpdate(nonceAccountAddresses: ["AaFj4THN8CJmDPyJjPuDpsfC5FZys2Wmczust5UfmqeN"]))
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("9PGftXH39kRKndTxL4hQppfonLMZQpWWWzvaHzYsAcLy")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableData(approverPublicKey: "3tSshpPL1WyNR7qDfxPffinndQmgfvTGoZc3PgL65Z9o").toHexString(),
            "0201040869ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c7152ae5404ca4d115addf760a932a2564636c071f3d93077c7722926026963d760e8e3dffb3877aaf1f737715f58920c52f4fcec66fab4ac69bb95f0ad69e33bcd7d17a6a48d07bbbf8d76e02379e0758f4580f3cb34a56980929e72e9b0d58e97206a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b21000000000000000000000000000000000000000000000000000000000000000000000000095f6d73715ba2affc6e25f8845e8f18908d92a129f233413b34d675d6fbd03d7c91fdec5cfa84288fc1e5d1732f0cc5ebba8ba90e1720fc85cf8f328bd1529a020603020400040400000007030301052209019eeebc4458643d9d4e03275c4e0c7fa3f6b9d550948e0e7a6768da4e9a5e1e51"
        )
    }

    func testWalletConfigPolicyUpdateInitiationRequest() throws {
        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(),
            initiatorIsApprover: true
        )
        let requestType: SolanaApprovalRequestType = getWalletConfigPolicyUpdate(nonceAccountAddresses: ["5osJEyGL1Ryiv9jedyhjnMqXHQaAM6A5PK253DTCTVdf"])
        let request = getWalletInitiationRequest(requestType, initiation: initiation)
        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "57cd2b0b1df0dd87e9001553716f2f4e9e1d2a8d0f4019f3048584cd3e83b385".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: [CensoApi.Nonce("7r8cdEASTnapMjhk569Kwq7mtWwaqjMmkxYe75PBCCK5")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ").toHexString(),
            "0301040969ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c7154bccd7a4522437daafe21e92b2b39dc596693b65aa9998ba1d961371884161272ba22d14fd3198775d3b9d1b22d6b48743f502ac2129cdf0094af144febf066647705611fa76d9ad3d1f58734c7ddc3476ef2e1317d807cb3b367a67ff75f83eff90e321f14ded704cbb267d1cbd7c0e9ae8c5e3ccbb6f47c95bbf75d5a924a606a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b21000000000000000000000000000000000000000000000000000000000000000000000000095f6d73715ba2affc6e25f8845e8f18908d92a129f233413b34d675d6fbd03d65bc30ccd8e88f4b8d5cf5903523b520f1cf0dea124d428b55038269c03609bc030703030500040400000007020001340000000080b2720000000000b803000000000000095f6d73715ba2affc6e25f8845e8f18908d92a129f233413b34d675d6fbd03d08050104020600560e0000000000000000000000000000000000000000000000000000000000000000000000000000000000025046000000000000020001358bd353729e02da524daff5551b39a3560970f30898fb5eb106986174088441"
        )
    }
    

    func testBalanceAccountSettingsUpdateApprovalRequest() throws {
        let request = getApprovalRequest(getBalanceAccountSettingsUpdate(nonceAccountAddresses: ["CpBzxGEDYnzi9jfGteSR6sCnmtT9XwirXQaCtSvmWnka"]))
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("QRKqHqP5SNEngXrcK2QeAR2nqx9AmwbHrmYF49ZbkEK")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableData(approverPublicKey: "7AH35qStXtrUgRkmqDmhjufNHjF74R1A9cCKT3C3HaAR").toHexString(),
            "0201040869ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c7155b867b0ff902f8bd3503e7a6c3ba5a94b90bd26858f6de78aa0913af0d8be7c6af874a8154f0de3ee6ff1668b3c18c49d62445d051d6b5cdcd6f5ada742c7d5bbe5ad75c51ec9e4c5d99214b8857b1d3ef76e40960b3ce2160a1c70fb0047e3606a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b21000000000000000000000000000000000000000000000000000000000000000000000000095f6d73715ba2affc6e25f8845e8f18908d92a129f233413b34d675d6fbd03d05ffdcd59d8f12aab0f8644eb0a57db2187baf6cc1e0115a977082f2ecd541200206030204000404000000070303010522090105339c334afb37619a4fd2bb47a885e8e1a72c52696893d8188666d0995a17b9"
        )
    }

    func testBalanceAccountSettingsUpdateUpdateInitiationRequest() throws {
        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(),
            initiatorIsApprover: true
        )
        let requestType: SolanaApprovalRequestType = getBalanceAccountSettingsUpdate(nonceAccountAddresses: ["CL8fZq5BzjCBXmixSMKqBsFoCLSFxqN6GvheDQ68HP44"])
        let request = getWalletInitiationRequest(requestType, initiation: initiation)
        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "514c07777ad9cd72f1493191f785170e1c14c5e37c9c6714863c9fa425965545".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: [CensoApi.Nonce("J2gVnUf56KpHARmwbagi3sX2TFHXNBUBGugXtvJrgxJq")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ").toHexString(),
            "0301040969ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c715be5ad75c51ec9e4c5d99214b8857b1d3ef76e40960b3ce2160a1c70fb0047e362ba22d14fd3198775d3b9d1b22d6b48743f502ac2129cdf0094af144febf0666a8574221c4298fd6dd12f8d67ac57a7e3586087ff177defef319a8f2b7ae8a99ff90e321f14ded704cbb267d1cbd7c0e9ae8c5e3ccbb6f47c95bbf75d5a924a606a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b21000000000000000000000000000000000000000000000000000000000000000000000000095f6d73715ba2affc6e25f8845e8f18908d92a129f233413b34d675d6fbd03dfd04eac9b2ed33f69fc778f2c3d9e413e041a3a07bf3fa787f1c14301000214e030703030500040400000007020001340000000080b2720000000000b803000000000000095f6d73715ba2affc6e25f8845e8f18908d92a129f233413b34d675d6fbd03d080501040206004e120000000000000000000000000000000000000000000000000000000000000000000000000000000000b59460e652df36f1ffb509cdf44bb3469f9054f93f8f707fe56685cdc6fc9c3301010000"
        )
    }

    func testBalanceAccountPolicyUpdateApprovalRequest() throws {
        let request = getApprovalRequest(getBalanceAccountPolicyUpdate(nonceAccountAddresses: ["BzZpoiceSXQTtrrZUMU67s6pCJzqCDJAVvgJCRw64fJV"]))
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("BeAVku8zsY9b1SzKU1UPkyqr6feVtiK7FS5bGHjfFArp")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableData(approverPublicKey: "CDrdR8xX8t83eXxB2ESuHp9AxkiJkUuKnD98zyDfMtrG").toHexString(),
            "02010408d5259a75898e5c16f1b0675c496a9f8ee74dd7687f234ba93c0ff09dfee8af34a6bba3eafd49e6bf5e8facf0faeea7cf500c019cd18cfa625f764213df7b8bd5a3541700f919ae296291c89fcff67de5d3cc0d941dfd342c85e641f6cea2cb56bb2b351f441f46df2039f49e8cd3f01079a908cad599a84079cb8189b218f57806a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b2100000000000000000000000000000000000000000000000000000000000000000000000074252b614aa502d0fa9eb2aef6eb7b43c25b6db7a61b70ae56b0cde9770fe09b9e1a189ce3273e79eef0d169e15ced5902ca2a4a680fc7f710ef4513ef02ebdd020603020400040400000007030301052209019373d32f7e0c28081730f51d9bb7f4f2c52c488b4e706a133f52a5768fcf4453"
        )
    }

    func testBalanceAccountPolicyUpdateInitiationRequest() throws {
        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(),
            initiatorIsApprover: true
        )
        let requestType: SolanaApprovalRequestType = getBalanceAccountPolicyUpdate(nonceAccountAddresses: ["5Fx8Nk98DbUcNUe4izqJkcYwfaMGmKRbXi1A7fVPfzj7"])
        let request = getWalletInitiationRequest(requestType, initiation: initiation)
        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "370349daceb62cb1ad6f37fbaba12dc72e36367c57b2ee976527609cd8d3f63e".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: [CensoApi.Nonce("DvKqKEBaJ71C5Hw8Yn45NvsYhpXfAYHybBbUa17nHcUm")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "4q8ApWsB3rSW2HPFwc1aWmGgcBMfj7tSKBbb5sBGAB6h").toHexString(),
            "03010409d5259a75898e5c16f1b0675c496a9f8ee74dd7687f234ba93c0ff09dfee8af34bb2b351f441f46df2039f49e8cd3f01079a908cad599a84079cb8189b218f57838e70bc45546b0d63742dee544ecc6870f66da475c800d2d793c766b03266cca3f4336251703628ce12796daa20166a1f0da8a9a972775f9f04a256482e2bedec43a8066d7b0612d9abc74bf23e9bc1230258306dcb561755b8d71c5ad38d5f406a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b2100000000000000000000000000000000000000000000000000000000000000000000000074252b614aa502d0fa9eb2aef6eb7b43c25b6db7a61b70ae56b0cde9770fe09bbff5520f20afb88a51a9a0630fb5bc2738f26b68af438c6a1750a68a4c2fc3c6030703030500040400000007020001340000000080b2720000000000b80300000000000074252b614aa502d0fa9eb2aef6eb7b43c25b6db7a61b70ae56b0cde9770fe09b08050104020600761a000000000000000000000000000000000000000000000000000000000000000000000000000000000046834450499b8d2edd17b54df5b3cd21a7e40369f8e3f8f072470cac3a271a7402100e0000000000000200011618435becfcd77198205d44019be2254d324294b97ef819e0c77d3af8b0e446"
        )
    }
    
    func testBalanceAccountAddressWhitelistUpdateApprovalRequest() throws {
        let request = getApprovalRequest(getBalanceAccountAddressWhitelistUpdate(nonceAccountAddresses: ["481dDMZGAiATXnLkBw1mEMdsJSwWWg3F2zHEsciaXZ98"]))
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("5XUBQaLXvXGvFArDtYpj3FW1TbNtZ3hP8fkrbzzY3VZJ")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableData(approverPublicKey: "FuneCbHNcAmaG9gEyisDYiZFLiYTGsuVsFMArXJDR3np").toHexString(),
            "02010408d5259a75898e5c16f1b0675c496a9f8ee74dd7687f234ba93c0ff09dfee8af34dd896d086f2c63e124ed47d94ee7b4932644e826e8280cb345893312aa199bc92e5ed518e5ea088f46ae95e2cb452fc7be22322d0a63e0ef7a820e8aa2593d7759427bbc05d796626ca3c12d0b3553f51e4a0a0582be08acfed19d4d8fa6ca3106a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b210000000000000000000000000000000000000000000000000000000000000000000000007bd238678c7de6666b1fa72f0423be16b875681575a02d9bfb142bed5c64ea35433ce76291f054c3712f68b3fc11a56a6a3f2e5447b3eb7d387ddc739ce419610206030204000404000000070303010522090161b966b30dc8507d2afec35e43873267933214a601565865b80372ad926dca6d"
        )
    }

    func testBalanceAccountAddressWhitelistUpdateInitiationRequest() throws {
        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(),
            initiatorIsApprover: true
        )
        let requestType: SolanaApprovalRequestType = getBalanceAccountAddressWhitelistUpdate(nonceAccountAddresses: ["9LGMMPep1WKdiNNwicDvx8JiwgtBKPWhidaSv3rVUNz"])
        let request = getWalletInitiationRequest(requestType, initiation: initiation)
        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "a9989f27d789b3c2266db5dbd1420e2831cacbb161d6e95bd48323911560fd11".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: [CensoApi.Nonce("Bb2XveQNyXVBJvJUPnsbhRtYqePUi8xbvBaJxk96BKDG")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "4AuJTW9fTnbPUq3LDAehK1CHsENF3x8X9vKnDwCUbTpk").toHexString(),
            "03010409d5259a75898e5c16f1b0675c496a9f8ee74dd7687f234ba93c0ff09dfee8af3459427bbc05d796626ca3c12d0b3553f51e4a0a0582be08acfed19d4d8fa6ca312f1c6ccaca0b0a0d12b938444f2ec6a9ec82b810394c64237a4651c5a41d4cd902226dd9d2e98d75fab1c2b62b8b007bab361b66ddffaa2362d30e8d8b915e3702827f15215947e7af780bb61613d832c508101f217f8c259828ffc4680fbcde06a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b210000000000000000000000000000000000000000000000000000000000000000000000007bd238678c7de6666b1fa72f0423be16b875681575a02d9bfb142bed5c64ea359d4c59b0c3139035ef4ad8c1c52ed58a7daf2db23646c0704575e009c35fac6f030703030500040400000007020001340000000080b2720000000000b8030000000000007bd238678c7de6666b1fa72f0423be16b875681575a02d9bfb142bed5c64ea35080501040206006d2100000000000000000000000000000000000000000000000000000000000000000000000000000000005560c327edbddd0faa5fe1ed8ff2e8da684374eb45e2cdd67cba4f3bb258fbd50201021b642a192de6a4165d92cf0e3d0c00e6ec86f02d6c71c537a879749da2200b91"
        )
    }

    func testBalanceAccountNameUpdateApprovalRequest() throws {
        let request = getApprovalRequest(getBalanceAccountNameUpdate(nonceAccountAddresses: ["AaFj4THN8CJmDPyJjPuDpsfC5FZys2Wmczust5UfmqeN"]))
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("9PGftXH39kRKndTxL4hQppfonLMZQpWWWzvaHzYsAcLy")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableData(approverPublicKey: "GYFxPGjuBXYKg1S91zgpVZCLP4guLGRho27bTAkAzjVL").toHexString(),
            "02010408d5259a75898e5c16f1b0675c496a9f8ee74dd7687f234ba93c0ff09dfee8af34e6e137f1b3e582e55db0f594a6cb6f05d5a08fc71d7413042921bf24f72e73eb8e3dffb3877aaf1f737715f58920c52f4fcec66fab4ac69bb95f0ad69e33bcd75c5c48251d37fc912ce1ac482a5b79e5f904d3202d47287f39edf2e1b6bb241006a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b2100000000000000000000000000000000000000000000000000000000000000000000000064424795ac2edb4b21b281bd120d0ababb12d4ae690773f41f5f61027a7add9f7c91fdec5cfa84288fc1e5d1732f0cc5ebba8ba90e1720fc85cf8f328bd1529a02060302040004040000000703030105220901ebdcefe98317428b88db3ec8c27fee8f20b12efaddbe4b6de661f8b74c0b509e"
        )
    }

    func testBalanceAccountNameUpdateInitiationRequest() throws {
        let initiation = MultisigOpInitiation(
            opAccountCreationInfo: getOpAccountCreationInfo(),
            initiatorIsApprover: true
        )
        let requestType: SolanaApprovalRequestType = getBalanceAccountNameUpdate(nonceAccountAddresses: ["AaFj4THN8CJmDPyJjPuDpsfC5FZys2Wmczust5UfmqeN"])
        let request = getWalletInitiationRequest(requestType, initiation: initiation)
        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "7707e53ddb688826e19d5d1d651450222c3d6cf73680fd331430278bba237328".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: initiation,
            requestType: requestType,
            nonces: [CensoApi.Nonce("9PGftXH39kRKndTxL4hQppfonLMZQpWWWzvaHzYsAcLy")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "Bg38YKHxGQrVRMB254yCKgVjtRapi68H4SD1RCiwWo7b").toHexString(),
            "03010409d5259a75898e5c16f1b0675c496a9f8ee74dd7687f234ba93c0ff09dfee8af345c5c48251d37fc912ce1ac482a5b79e5f904d3202d47287f39edf2e1b6bb24109e94ede101ab5be0734b6500e0fc10b51ca23e89e67391657197fd7b2529c13e8e3dffb3877aaf1f737715f58920c52f4fcec66fab4ac69bb95f0ad69e33bcd73468bd8cddd071cd3bb0a3c50c4b5cab7dfe4ae3328081889ebabd48d8b7c9c006a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b2100000000000000000000000000000000000000000000000000000000000000000000000064424795ac2edb4b21b281bd120d0ababb12d4ae690773f41f5f61027a7add9f7c91fdec5cfa84288fc1e5d1732f0cc5ebba8ba90e1720fc85cf8f328bd1529a030703030500040400000007020001340000000080b2720000000000b80300000000000064424795ac2edb4b21b281bd120d0ababb12d4ae690773f41f5f61027a7add9f080501040206006a1800000000000000000000000000000000000000000000000000000000000000000000000000000000003c69f1851b7318b7f14f04992a80df6054b8bc4f325f24bce0d378d770e870c44e637072f628e09a14c28a2559381705b1674b55541eb62eb6db926704666ac5"
        )
    }

    func testLoginApproval() throws {
        let jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImF1ZCI6IlNvbHIifQ.SWCJDd6B_m7xr_puQH-wgbxvXyJYXH9lTpldOU0eQKc"
        let email = "sample@email.co"
        let name = "Sample User Name"
        let request = getApprovalRequest(getLoginApproval(jwtToken, email: email, name: name))
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [],
            email: "dont care"
        )
        XCTAssertEqual(
            String(decoding: try approvalRequest.signableData(approverPublicKey: "GYFxPGjuBXYKg1S91zgpVZCLP4guLGRho27bTAkAzjVL"), as: UTF8.self),
            jwtToken
        )
    }
    
    func testAcceptVaultInvitation() throws {
        let approvalData = "{\"id\": \"422e3504-4eea-493a-a0dd-64a001115540\", \"submitDate\": \"2022-06-21T14:20:38.145+00:00\", \"submitterName\": \"User 1\", \"submitterEmail\": \"authorized1@org1\", \"numberOfDispositionsRequired\": 1, \"numberOfApprovalsReceived\": 0, \"numberOfDeniesReceived\": 0, \"details\": {\"type\": \"AcceptVaultInvitation\", \"vaultGuid\": \"58e03f93-b9bc-4f22-b485-8e7a0abd8440\", \"vaultName\": \"Test Organization 1\"}, \"vaultName\": \"Test Organization 1\"}\n"

        let request: ApprovalRequest = Mock.decodeJsonType(data: approvalData.data(using: .utf8)!)
        let approvalDispositionRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [],
            email: "dont care"
        )
        switch request.requestType {
        case .acceptVaultInvitation:
            XCTAssertEqual(
                String(decoding: try approvalDispositionRequest.signableData(approverPublicKey: "GYFxPGjuBXYKg1S91zgpVZCLP4guLGRho27bTAkAzjVL"), as: UTF8.self),
                "Test Organization 1"
            )
        default:
            XCTFail("should not get here")
        }
        
    }
    
    func testPasswordReset() throws {
        let approvalData = "{\"id\": \"422e3504-4eea-493a-a0dd-64a001115540\", \"submitDate\": \"2022-06-21T14:20:38.145+00:00\", \"submitterName\": \"User 1\", \"submitterEmail\": \"authorized1@org1\", \"numberOfDispositionsRequired\": 1, \"numberOfApprovalsReceived\": 0, \"numberOfDeniesReceived\": 0, \"details\": {\"type\": \"PasswordReset\"}}\n"

        let request: ApprovalRequest = Mock.decodeJsonType(data: approvalData.data(using: .utf8)!)
        let approvalDispositionRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [],
            email: "dont care"
        )
        switch request.requestType {
        case .passwordReset:
            XCTAssertEqual(
                String(decoding: try approvalDispositionRequest.signableData(approverPublicKey: "GYFxPGjuBXYKg1S91zgpVZCLP4guLGRho27bTAkAzjVL"), as: UTF8.self),
                request.id
            )
        default:
            XCTFail("should not get here")
        }
        
    }
    
    func testBuildGetMultipleAccountsRequest() throws {
    
        var getMultipleAccountsRequest = CensoApi.GetMultipleAccountsRequest.init(
            accountKeys: ["GYFxPGjuBXYKg1S91zgpVZCLP4guLGRho27bTAkAzjVL", "AaFj4THN8CJmDPyJjPuDpsfC5FZys2Wmczust5UfmqeN", "9PGftXH39kRKndTxL4hQppfonLMZQpWWWzvaHzYsAcLy"]
        )

        getMultipleAccountsRequest.id = "B199C55D-F8F0-4AF0-8D4B-B6AF6A3DA0B9"

        XCTAssertEqual(String(decoding: Mock.encodeJsonType(value: getMultipleAccountsRequest), as: UTF8.self), "{\"id\":\"B199C55D-F8F0-4AF0-8D4B-B6AF6A3DA0B9\",\"method\":\"getMultipleAccounts\",\"jsonrpc\":\"2.0\",\"params\":[[\"GYFxPGjuBXYKg1S91zgpVZCLP4guLGRho27bTAkAzjVL\",\"AaFj4THN8CJmDPyJjPuDpsfC5FZys2Wmczust5UfmqeN\",\"9PGftXH39kRKndTxL4hQppfonLMZQpWWWzvaHzYsAcLy\"],{\"encoding\":\"base64\",\"commitment\":\"finalized\"}]}")
       
    }

    func testExtractNonces() throws {
        
        let response = "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":402},\"value\":[{\"data\":[\"AAAAAAEAAADVJZp1iY5cFvGwZ1xJap+O503XaH8jS6k8D/Cd/uivNCdJE0k9Ajpn/cEy3TSbbYl5dgEsceAKtAIKa1nvxf6QiBMAAAAAAAA=\",\"base64\"],\"executable\":false,\"lamports\":1447680,\"owner\":\"11111111111111111111111111111111\",\"rentEpoch\":0},{\"data\":[\"AAAAAAEAAADVJZp1iY5cFvGwZ1xJap+O503XaH8jS6k8D/Cd/uivNPowQba3TsNG8RNMBrZK/RZighANP8iUyL4yx85rzJDLiBMAAAAAAAA=\",\"base64\"],\"executable\":false,\"lamports\":1447680,\"owner\":\"11111111111111111111111111111111\",\"rentEpoch\":0},{\"data\":[\"AAAAAAEAAADVJZp1iY5cFvGwZ1xJap+O503XaH8jS6k8D/Cd/uivNIQJ8qqFaevM1IJGpCc4YNY67rnrwwyslHS6t+htayrBiBMAAAAAAAA=\",\"base64\"],\"executable\":false,\"lamports\":1447680,\"owner\":\"11111111111111111111111111111111\",\"rentEpoch\":0},]},\"id\":\"5c0c319a-4482-45c3-b9b9-d54975c1c4eb\"}"
        let getAccountInfoResponse: CensoApi.GetMultipleAccountsResponse = Mock.decodeJsonType(data: response.data(using: .utf8)!)
        XCTAssertEqual(
            [
                CensoApi.Nonce("3eMXeaEkwY5C6UxB6jsMjRGAsDcozgMCdjbZoowSTXZy"),
                CensoApi.Nonce("HqdbyB576ggyavQPaodKiS8XNPHBoo95rb75Le7XzXrr"),
                CensoApi.Nonce("9tRccoR8XEVfP32LEZYtZuR8YFYFbPg9kCKnBicdPQHN")
            ],
            getAccountInfoResponse.nonces
        )
    }
    
    func testSignDataForPlainTextApprovalRequest() throws {
        let approvalData = "{\"id\": \"6a196209-b207-47a8-aff0-b609324c9e0e\", \"submitDate\": \"2022-09-10T10:35:20.161+00:00\", \"submitterName\": \"User 1\", \"submitterEmail\": \"authorized1@org4\", \"approvalTimeoutInSeconds\": 18000, \"numberOfDispositionsRequired\": 2, \"numberOfApprovalsReceived\": 1, \"numberOfDeniesReceived\": 0, \"details\": {\"type\": \"SignData\", \"base64Data\": \"U29tZSCxbmFyeSDadGE=\", \"signingData\": {\"feePayer\": \"87VXbkJsqdDvXYfDBtS4kW4TcFor7ogofZXbXjT7t7AU\", \"walletProgramId\": \"Hk3CaEtWizNe4tJ8heB1MEsFXuc82PaEgKY3V1eRnFHt\", \"multisigOpAccountAddress\": \"B9k6TF3TqxxErAjm9xbEM1wo6pXL7awUBVwz9GHSvK4d\", \"walletAddress\": \"5u9Q3gR5ZEHG3FYben6b4XnRUgsdV1CGzUp1CGo2xpcp\", \"nonceAccountAddresses\": [\"GG9poSiQMRyZRVR8vSATYZBFcRncamRDyMiumDXDkgHM\"], \"nonceAccountAddressesSlot\": 481, \"initiator\": \"5SrmRzk1CGbHLt8UrNdBXVLtSeje3zW9y9CpfnrS78w\", \"strikeFeeAmount\": 0, \"feeAccountGuidHash\": \"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\", \"walletGuidHash\": \"RATnHZIZKJRvD0BHwo2on7xqdHNtVMS3U9dqD3o3fLc=\"}}, \"vaultName\": \"Test Organization 4\"}\n"


        let request: ApprovalRequest = Mock.decodeJsonType(data: approvalData.data(using: .utf8)!)
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("2U5pPGeproZb8smwt9mSAp5zkss7C1xrBZ1ixYiA65Cq")],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableData(approverPublicKey: "GBqNjtAuRCG6ZMc5qahkZgdNkDWozunqCrk9kUZofpjg").toHexString(),
            "0201040869ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c715e1a5cf3fab8f98681bb1c2ab56b568f2130aced971afe993db6cb89f505a5057e2c0fe5804959c1384f0471ea41f4b6d80b3e54736755d516b5db6f5f665956896d23e0675489b40443f764b8b368efa0e13694c2b6090f18667db0231c44ef206a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b21000000000000000000000000000000000000000000000000000000000000000000000000f8c173dfe79d7c7b9277684179dc740f657b46bc391c72e99e7695ee78e76c7315cbd0b9873580854605c61c9c08684e0db3256877269949b1bb7e3dfbf0d276020603020400040400000007030301052209016aa58199b0486c9279964a911dcf8f165a2004568280e60063603a59d037d114"
        )
    }

    func testSignDataForPlainTextInitiationRequest() throws {
        let approvalData = "{\"id\": \"6a196209-b207-47a8-aff0-b609324c9e0e\", \"submitDate\": \"2022-09-10T10:35:20.161+00:00\", \"submitterName\": \"User 1\", \"submitterEmail\": \"authorized1@org4\", \"approvalTimeoutInSeconds\": null, \"numberOfDispositionsRequired\": 2, \"numberOfApprovalsReceived\": 0, \"numberOfDeniesReceived\": 0, \"details\": {\"type\": \"MultisigOpInitiation\", \"details\": {\"type\": \"SignData\", \"base64Data\": \"U29tZSCxbmFyeSDadGE=\", \"signingData\": {\"feePayer\": \"87VXbkJsqdDvXYfDBtS4kW4TcFor7ogofZXbXjT7t7AU\", \"walletProgramId\": \"Hk3CaEtWizNe4tJ8heB1MEsFXuc82PaEgKY3V1eRnFHt\", \"multisigOpAccountAddress\": \"11111111111111111111111111111111\", \"walletAddress\": \"5u9Q3gR5ZEHG3FYben6b4XnRUgsdV1CGzUp1CGo2xpcp\", \"nonceAccountAddresses\": [\"GqH8ELz24NLWArdzGFa8Y29eLHgfvCpJhnAQjAvycznf\"], \"nonceAccountAddressesSlot\": 479, \"initiator\": \"5SrmRzk1CGbHLt8UrNdBXVLtSeje3zW9y9CpfnrS78w\", \"strikeFeeAmount\": 0, \"feeAccountGuidHash\": \"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\", \"walletGuidHash\": \"RATnHZIZKJRvD0BHwo2on7xqdHNtVMS3U9dqD3o3fLc=\"}}, \"opAccountCreationInfo\": {\"accountSize\": 3649, \"minBalanceForRentExemption\": 26287920}, \"initiatorIsApprover\": true}, \"vaultName\": \"Test Organization 4\"}\n"

        let request: ApprovalRequest = Mock.decodeJsonType(data: approvalData.data(using: .utf8)!)
        let pk = try Curve25519.Signing.PrivateKey.init(rawRepresentation: "afbdbb77f072edf581050da4f60bdaf543fe4bed493e011bb4f411345940976e".data(using: .hexadecimal)!)
        let initiationRequest = CensoApi.InitiationRequest(
            disposition: .Approve,
            requestID: request.id,
            initiation: getOpAccountCreationInfo(request)!,
            requestType: request.requestType,
            nonces: [CensoApi.Nonce("mXY4UKHQeS8pRva5WjuKeTCuCFYYCixZuKh2Vk1aKo6")],
            email: "dont care",
            opAccountPrivateKey: pk
        )

        XCTAssertEqual(
            try initiationRequest.signableData(approverPublicKey: "5SrmRzk1CGbHLt8UrNdBXVLtSeje3zW9y9CpfnrS78w").toHexString(),
            "0301040969ab8cb05413af9614f898a1f1fdfbc07e7ad5eb2eb1d0f1c49f448bd179c71596d23e0675489b40443f764b8b368efa0e13694c2b6090f18667db0231c44ef201238f9e5b8ccbc602ca478dc3afeb66d39794afabb6d44e0bffc9182b7d91bceb3d6a3962d0b55e5f5c423b991ef81f53e5839f3c29cc578f384d991246f6b448ca71d727e64a9d5a5df685e84832e44220815d3deb8f16866a54cb5e047b6106a7d517192c568ee08a845f73d29788cf035c3145b21ab344d8062ea940000006a7d51718c774c928566398691d5eb68b5eb8a39b4b6d5c73555b21000000000000000000000000000000000000000000000000000000000000000000000000f8c173dfe79d7c7b9277684179dc740f657b46bc391c72e99e7695ee78e76c730b68150c1630c6c8bb55c0e65252408e01d52f1f4c78d59dd6c6d3b049566d810307030305000404000000070200013400000000301f910100000000410e000000000000f8c173dfe79d7c7b9277684179dc740f657b46bc391c72e99e7695ee78e76c73080501040206004c2300000000000000000000000000000000000000000000000000000000000000000000000000000000002000ec95cd80234483ef831d02c21c9ee4ec4f714a44603eaee22666681c496a83dd"
        )
    }
    
    func testBitcoinWithdrawalApproval() throws {
        let approvalData = "{\"id\":\"77475988-fd42-41c0-8ef6-cba19c1b1251\",\"submitDate\":\"2022-09-28T22:58:12.035+00:00\",\"submitterName\":\"User 1\",\"submitterEmail\":\"authorized1@org1\",\"approvalTimeoutInSeconds\":3600,\"numberOfDispositionsRequired\":1,\"numberOfApprovalsReceived\":0,\"numberOfDeniesReceived\":0,\"details\":{\"type\":\"WithdrawalRequest\",\"account\":{\"identifier\":\"a7c36ae6-7ccf-4051-937b-4dfa34a29736\",\"name\":\"Bitcoin Wallet 1\",\"accountType\":\"BalanceAccount\",\"address\":\"mxUpwv18LoZWg6k7ksGoj3r8geruTcwqZq\"},\"symbolAndAmountInfo\":{\"symbolInfo\":{\"symbol\":\"BTC\",\"symbolDescription\":\"Bitcoin\",\"imageUrl\":\"https://s3.us-east-1.amazonaws.com/strike-public-assets/logos/BTC.png\"},\"amount\":\"0.50010380\",\"nativeAmount\":\"0.50010380\",\"usdEquivalent\":\"31581.55\",\"fee\":null,\"replacementFee\":null},\"destination\":{\"name\":\"Bitcoin Wallet 2\",\"address\":\"mwRPxwxTS9YD2bkUAqKYcHCPMpUoMemhPo\"},\"signingData\":{\"type\":\"bitcoin\",\"childKeyIndex\":0,\"transaction\":{\"version\":1,\"txIns\":[{\"txId\":\"81788c968daae8c6ea30a5041f283a798ad5ab253cb99ef2f0d0b167f937dd77\",\"index\":1,\"amount\":20000000,\"inputScriptHex\":\"76A914BA132C598CAA68EDEE903578AE11B6B03BFDC78588AC\",\"base64HashForSignature\":\"OdGGt+Yh9Fp1wjHVGwpbmVJnjWOdFnZpeC+F9l+HG8g=\"},{\"txId\":\"5b4f03ab2e30fc4b716d4aefc47a6db59cdfca0a788068ce5131278e9d9f3d33\",\"index\":1,\"amount\":20000000,\"inputScriptHex\":\"76A914BA132C598CAA68EDEE903578AE11B6B03BFDC78588AC\",\"base64HashForSignature\":\"AnxjVJFcoqK4y3URV/UMI4F9jIER5bb2cDI+TtkMtMc=\"},{\"txId\":\"bb149f176978a86e83ab12a7aee4c21fd5830963d89af74064762c4f023d35ea\",\"index\":1,\"amount\":20000000,\"inputScriptHex\":\"76A914BA132C598CAA68EDEE903578AE11B6B03BFDC78588AC\",\"base64HashForSignature\":\"m73uZw7PDXkA5VzKxDEqdT+AMT2vwGvVcjzlRyd4a6E=\"}],\"txOuts\":[{\"index\":0,\"amount\":50000000,\"pubKeyScriptHex\":\"76A914AE74F20C5186F642F1396917DECF8246CEFDD13588AC\",\"address\":\"mwRPxwxTS9YD2bkUAqKYcHCPMpUoMemhPo\",\"isChange\":false},{\"index\":1,\"amount\":9989620,\"pubKeyScriptHex\":\"76A914BA132C598CAA68EDEE903578AE11B6B03BFDC78588AC\",\"address\":\"mxUpwv18LoZWg6k7ksGoj3r8geruTcwqZq\",\"isChange\":true}],\"totalFee\":10380}}},\"vaultName\":\"Test Organization 1\"}\n"
        
        let request: ApprovalRequest = Mock.decodeJsonType(data: approvalData.data(using: .utf8)!)
        
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableDataList(approverPublicKey: "4Gyit71SY3zUUmDMvAT3Lqbex8wBhWJRx8xpEXd5qq66").map( {$0.base64EncodedString()} ),
            ["OdGGt+Yh9Fp1wjHVGwpbmVJnjWOdFnZpeC+F9l+HG8g=", "AnxjVJFcoqK4y3URV/UMI4F9jIER5bb2cDI+TtkMtMc=", "m73uZw7PDXkA5VzKxDEqdT+AMT2vwGvVcjzlRyd4a6E="]
        )
    }
    
    func testBitcoinWithdrawalFeeBumpApproval() throws {
        let approvalData = "{\"id\":\"77475988-fd42-41c0-8ef6-cba19c1b1251\",\"submitDate\":\"2022-09-28T22:58:12.035+00:00\",\"submitterName\":\"User 1\",\"submitterEmail\":\"authorized1@org1\",\"approvalTimeoutInSeconds\":3600,\"numberOfDispositionsRequired\":1,\"numberOfApprovalsReceived\":0,\"numberOfDeniesReceived\":0,\"details\":{\"type\":\"WithdrawalRequest\",\"account\":{\"identifier\":\"a7c36ae6-7ccf-4051-937b-4dfa34a29736\",\"name\":\"Bitcoin Wallet 1\",\"accountType\":\"BalanceAccount\",\"address\":\"mxUpwv18LoZWg6k7ksGoj3r8geruTcwqZq\"},\"symbolAndAmountInfo\":{\"symbolInfo\":{\"symbol\":\"BTC\",\"symbolDescription\":\"Bitcoin\",\"imageUrl\":\"https://s3.us-east-1.amazonaws.com/strike-public-assets/logos/BTC.png\"},\"amount\":\"0.50010380\",\"nativeAmount\":\"0.50010380\",\"usdEquivalent\":\"31581.55\",\"fee\":{\"amount\":\"0.0000123\",\"symbolInfo\":{\"symbol\":\"BTC\",\"symbolDescription\":\"Bitcoin\",\"imageUrl\":\"https://s3.us-east-1.amazonaws.com/strike-public-assets/logos/BTC.png\"},\"usdEquivalent\":\"7.76\"},\"replacementFee\":{\"amount\":\"0.0000246\",\"symbolInfo\":{\"symbol\":\"BTC\",\"symbolDescription\":\"Bitcoin\",\"imageUrl\":\"https://s3.us-east-1.amazonaws.com/strike-public-assets/logos/BTC.png\"},\"usdEquivalent\":\"15.52\"}},\"destination\":{\"name\":\"Bitcoin Wallet 2\",\"address\":\"mwRPxwxTS9YD2bkUAqKYcHCPMpUoMemhPo\"},\"signingData\":{\"type\":\"bitcoin\",\"childKeyIndex\":0,\"transaction\":{\"version\":1,\"txIns\":[{\"txId\":\"81788c968daae8c6ea30a5041f283a798ad5ab253cb99ef2f0d0b167f937dd77\",\"index\":1,\"amount\":20000000,\"inputScriptHex\":\"76A914BA132C598CAA68EDEE903578AE11B6B03BFDC78588AC\",\"base64HashForSignature\":\"OdGGt+Yh9Fp1wjHVGwpbmVJnjWOdFnZpeC+F9l+HG8g=\"},{\"txId\":\"5b4f03ab2e30fc4b716d4aefc47a6db59cdfca0a788068ce5131278e9d9f3d33\",\"index\":1,\"amount\":20000000,\"inputScriptHex\":\"76A914BA132C598CAA68EDEE903578AE11B6B03BFDC78588AC\",\"base64HashForSignature\":\"AnxjVJFcoqK4y3URV/UMI4F9jIER5bb2cDI+TtkMtMc=\"},{\"txId\":\"bb149f176978a86e83ab12a7aee4c21fd5830963d89af74064762c4f023d35ea\",\"index\":1,\"amount\":20000000,\"inputScriptHex\":\"76A914BA132C598CAA68EDEE903578AE11B6B03BFDC78588AC\",\"base64HashForSignature\":\"m73uZw7PDXkA5VzKxDEqdT+AMT2vwGvVcjzlRyd4a6E=\"}],\"txOuts\":[{\"index\":0,\"amount\":50000000,\"pubKeyScriptHex\":\"76A914AE74F20C5186F642F1396917DECF8246CEFDD13588AC\",\"address\":\"mwRPxwxTS9YD2bkUAqKYcHCPMpUoMemhPo\",\"isChange\":false},{\"index\":1,\"amount\":9989620,\"pubKeyScriptHex\":\"76A914BA132C598CAA68EDEE903578AE11B6B03BFDC78588AC\",\"address\":\"mxUpwv18LoZWg6k7ksGoj3r8geruTcwqZq\",\"isChange\":true}],\"totalFee\":10380}}},\"vaultName\":\"Test Organization 1\"}\n"
        
        let request: ApprovalRequest = Mock.decodeJsonType(data: approvalData.data(using: .utf8)!)
        
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [],
            email: "dont care"
        )
        XCTAssertEqual(
            try approvalRequest.signableDataList(approverPublicKey: "4Gyit71SY3zUUmDMvAT3Lqbex8wBhWJRx8xpEXd5qq66").map( {$0.base64EncodedString()} ),
            ["OdGGt+Yh9Fp1wjHVGwpbmVJnjWOdFnZpeC+F9l+HG8g=", "AnxjVJFcoqK4y3URV/UMI4F9jIER5bb2cDI+TtkMtMc=", "m73uZw7PDXkA5VzKxDEqdT+AMT2vwGvVcjzlRyd4a6E="]
        )
    }
    
    func testEthereumWithdrawalApproval() throws {
        let request = getApprovalRequest(getEthereumWithdrawalRequest())
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [],
            email: "dont care"
        )
        
        let signableData = try approvalRequest.signableData(approverPublicKey: "7AH35qStXtrUgRkmqDmhjufNHjF74R1A9cCKT3C3HaAR")
        
        XCTAssertEqual(
            signableData.hexEncodedString(),
            "135b4be7cb5b0cc080c32b361047a720c8eda961c1eed152d8f7d8f70b2b8b90"
        )
    }
    
    func testERC20WithdrawalApproval() throws {
        let request = getApprovalRequest(getERC20WithdrawalRequest())
        let approvalRequest = CensoApi.ApprovalDispositionRequest(
            disposition: .Approve,
            requestID: request.id,
            requestType: request.requestType,
            nonces: [],
            email: "dont care"
        )

        let signableData = try approvalRequest.signableData(approverPublicKey: "7AH35qStXtrUgRkmqDmhjufNHjF74R1A9cCKT3C3HaAR")

        XCTAssertEqual(
            signableData.hexEncodedString(),
            "030c5e07a21177f20510e81903d7ba8d8e2b3f354574529538f01f4047a19e69"
        )
    }

    func getOpAccountCreationInfo(_ request: ApprovalRequest) -> MultisigOpInitiation? {
        switch request.details {
        case .multisigOpInitiation(let initiation, _):
            return MultisigOpInitiation(opAccountCreationInfo: initiation.opAccountCreationInfo, initiatorIsApprover: initiation.initiatorIsApprover)
        default:
            return nil
        }
    }
}
