//
//  KeychainTests.swift
//  StrikeTests
//
//  Created by Brendan Flood on 10/6/22.
//


import XCTest
@testable import Strike
import BIP39

class KeychainTests: XCTestCase {
    
    func testGenerateKeys() throws {
        let phrase = "echo flat forget radio apology old until elite keep fine clock parent cereal ticket dutch whisper flock junior pet six uphold gorilla trend spare"
        let rootSeed = try Mnemonic(phrase: phrase.components(separatedBy: " ")).seed
        let privateKeys = try PrivateKeys.fromRootSeed(rootSeed: rootSeed)
        
        XCTAssertEqual(
            privateKeys.solana.rawRepresentation,
            try Ed25519HierachicalPrivateKey.fromRootSeed(rootSeed: rootSeed).privateKey.rawRepresentation
        )
        
        XCTAssertEqual(
            privateKeys.bitcoin!.getBase58ExtendedPrivateKey(),
            try Secp256k1HierarchicalKey.fromRootSeed(
                rootSeed: rootSeed,
                derivationPath: Secp256k1HierarchicalKey.bitcoinDerivationPath
            ).getBase58ExtendedPrivateKey()
        )
        
        XCTAssertEqual(
            privateKeys.ethereum!.getBase58ExtendedPrivateKey(),
            try Secp256k1HierarchicalKey.fromRootSeed(
                rootSeed: rootSeed,
                derivationPath: Secp256k1HierarchicalKey.ethereumDerivationPath
            ).getBase58ExtendedPrivateKey()
        )
        
        let privateKeys2 = try privateKeys.bytes.privateKeys
        
        XCTAssertEqual(
            privateKeys.solana.rawRepresentation,
            privateKeys2.solana.rawRepresentation
        )
        
        XCTAssertEqual(
            privateKeys.bitcoin!.getBase58ExtendedPrivateKey(),
            privateKeys2.bitcoin?.getBase58ExtendedPrivateKey()
        )
        
        XCTAssertEqual(
            privateKeys.ethereum!.getBase58ExtendedPrivateKey(),
            privateKeys2.ethereum?.getBase58ExtendedPrivateKey()
        )
        
        let publicKeys = try privateKeys.publicKeys
        XCTAssertEqual(
            publicKeys,
            PublicKeys(
                solana: privateKeys.solana.encodedPublicKey,
                bitcoin: privateKeys.bitcoin?.getBase58ExtendedPublicKey(),
                ethereum: privateKeys.ethereum?.getBase58CompressedPublicKey()
            )
        )
        
        XCTAssertEqual(
            publicKeys,
            try publicKeys.bytes.publicKeys
        )
    }
    
    func testUserToRegisteredPublicKeys() throws {
        let org = StrikeApi.Organization(id: "", name: "")
        XCTAssertNil(
            StrikeApi.User(id: "", fullName: "", loginName: "", hasApprovalPermission: false, organization: org, useStaticKey: false, publicKeys: []).registeredPublicKeys
        )
        
        XCTAssertEqual(
            StrikeApi.User(id: "", fullName: "", loginName: "", hasApprovalPermission: false, organization: org, useStaticKey: false,
                           publicKeys: [StrikeApi.PublicKey(key: "F7JuLRBbyGAS9nAhDdfNX1LbckBAmCnKMB2xTdZfQS1n", walletType: WalletType.Solana)]).registeredPublicKeys,
            PublicKeys(solana: "F7JuLRBbyGAS9nAhDdfNX1LbckBAmCnKMB2xTdZfQS1n", bitcoin: nil)
        )
        
        XCTAssertEqual(
            StrikeApi.User(id: "", fullName: "", loginName: "", hasApprovalPermission: false, organization: org, useStaticKey: false,
                           publicKeys: [
                            StrikeApi.PublicKey(key: "F7JuLRBbyGAS9nAhDdfNX1LbckBAmCnKMB2xTdZfQS1n", walletType: WalletType.Solana),
                            StrikeApi.PublicKey(key: "xpub6GGm8SWYXzXt4T2giWaP67ajd9d5hnYkbgUFtxyBU9d4Q5hkXPr7JHtPJN5dD6uNVXb7EEpdZeXvG5XwFVWhUj4Q2ufhYH38fuHK9ERTy3d", walletType: WalletType.Bitcoin),
                            StrikeApi.PublicKey(key: "ABJuLRBbyGAS9nAhDdfNX1LbckBAmCnKMB2xTdZfQScd", walletType: WalletType.Ethereum)
                           ]).registeredPublicKeys,
            PublicKeys(solana: "F7JuLRBbyGAS9nAhDdfNX1LbckBAmCnKMB2xTdZfQS1n",
                       bitcoin: "xpub6GGm8SWYXzXt4T2giWaP67ajd9d5hnYkbgUFtxyBU9d4Q5hkXPr7JHtPJN5dD6uNVXb7EEpdZeXvG5XwFVWhUj4Q2ufhYH38fuHK9ERTy3d",
                       ethereum: "ABJuLRBbyGAS9nAhDdfNX1LbckBAmCnKMB2xTdZfQScd"
                      )
        )
        
        XCTAssertNotEqual(
            StrikeApi.User(id: "", fullName: "", loginName: "", hasApprovalPermission: false, organization: org, useStaticKey: false,
                           publicKeys: [
                            StrikeApi.PublicKey(key: "F7JuLRBbyGAS9nAhDdfNX1LbckBAmCnKMB2xTdZfQS1n", walletType: WalletType.Solana),
                            StrikeApi.PublicKey(key: "xpub6GGm8SWYXzXt4T2giWaP67ajd9d5hnYkbgUFtxyBU9d4Q5hkXPr7JHtPJN5dD6uNVXb7EEpdZeXvG5XwFVWhUj4Q2ufhYH38fuHK9ERTy3d", walletType: WalletType.Bitcoin),
                            StrikeApi.PublicKey(key: "ABJuLRBbyGAS9nAhDdfNX1LbckBAmCnKMB2xTdZfQScd", walletType: WalletType.Ethereum)
                           ]).registeredPublicKeys,
            PublicKeys(solana: "F7JuLRBbyGAS9nAhDdfNX1LbckBAmCnKMB2xTdZfQS1n",
                       bitcoin: "xpub6GGm8SWYXzXt4T2giWaP67ajd9d5hnYkbgUFtxyBU9d4Q5hkXPr7JHtPJN5dD6uNVXb7EEpdZeXvG5XwFVWhUj4Q2ufhYH38fuHK9ERTy3d",
                       ethereum: nil
                      )
        )
    }
    
}
