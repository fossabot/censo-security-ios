//
//  BipTests.swift
//  StrikeTests
//
//  Created by Brendan Flood on 6/8/22.
//

import XCTest
@testable import Strike
import BIP39

struct TestItem: Codable {
    let mnemonic: String
    let privateKey: String
    let publicKey: String
}

struct TestItems: Codable {
    let items: [TestItem]
}


class BipTests: XCTestCase {
    
    func testSolanaWithKnownDataSet() throws {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "solana-test-data", withExtension: "json") else {
            XCTFail("Missing file: test-data.json")
            return
        }
        let decoder = JSONDecoder()
        let testItems = try! decoder.decode(TestItems.self, from: try Data(contentsOf: url))
        for testItem in testItems.items {
            let ed25519PrivateKey = try Ed25519HierachicalPrivateKey.fromRootSeed(rootSeed: try Mnemonic(phrase: testItem.mnemonic.components(separatedBy: " ")).seed)
            // @solana/web3j code which generated this data set represents the private key as the actual private key(32 bytes) appended with public key (another 32 bytes)
            XCTAssertEqual(testItem.privateKey, (ed25519PrivateKey.privateKey.rawRepresentation + ed25519PrivateKey.privateKey.publicKey.rawRepresentation).toHexString().lowercased())
            XCTAssertEqual(testItem.publicKey, Base58.encode(ed25519PrivateKey.privateKey.publicKey.rawRepresentation.bytes))

        }
    }
    
    func testBitcoinWithKnownDataSet() throws {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "bitcoin-test-data", withExtension: "json") else {
            XCTFail("Missing file: test-data.json")
            return
        }
        let decoder = JSONDecoder()
        let testItems = try! decoder.decode(TestItems.self, from: try Data(contentsOf: url))
        for (index, testItem) in testItems.items[0..<200].enumerated() {
            print("processing \(index)")
            
            let rootSeed = try Mnemonic(phrase: testItem.mnemonic.components(separatedBy: " ")).seed
            let signingKey = try Secp256k1HierarchicalKey.fromRootSeed(rootSeed: rootSeed, derivationPath: Secp256k1HierarchicalKey.bitcoinDerivationPath)
                .derived(at: DerivationNode.notHardened(0))

            XCTAssertEqual(testItem.privateKey, signingKey.getBase58ExtendedPrivateKey())
            XCTAssertEqual(testItem.publicKey, signingKey.getBase58ExtendedPublicKey())
        
        }
    }
    
    func testMnemonicGenerationAndValidation() throws {
        // generate a new 24 word phrase and generate key
        let words = Mnemonic(strength: 256).phrase
        XCTAssertEqual(words.count, 24)
        let rootSeed = try Mnemonic(phrase: words).seed
        let hdKey = try Ed25519HierachicalPrivateKey.fromRootSeed(rootSeed: rootSeed)
        let signature = try hdKey.privateKey.signature(for: "Hello World".data(using: .utf16)!)
        
        // regenerate from same set and verify keys match
        let hdKey2 = try Ed25519HierachicalPrivateKey.fromRootSeed(rootSeed: try Mnemonic(phrase: words).seed)
        XCTAssertEqual(hdKey.privateKey.rawRepresentation.toHexString(), hdKey2.privateKey.rawRepresentation.toHexString())
        XCTAssertTrue(hdKey2.privateKey.publicKey.isValidSignature(signature, for: "Hello World".data(using: .utf16)!))
    }
    
    func testMnemonic() throws {
        XCTAssertTrue(
            Mnemonic.isValid(
                phrase: "echo flat forget radio apology old until elite keep fine clock parent cereal ticket dutch whisper flock junior pet six uphold gorilla trend spare".components(separatedBy: " ")
            )
        )
        XCTAssertFalse(
            Mnemonic.isValid(
                phrase: "echo flat forged radio apology old until elite keep fine clock parent cereal ticket dutch whisper flock junior pet six uphold gorilla trend spare".components(separatedBy: " ")
            )
        )
        XCTAssertFalse(
            Mnemonic.isValid(
                phrase: "echo flat forget radio apology new until elite keep fine clock parent cereal ticket dutch whisper flock junior pet six uphold gorilla trend spare".components(separatedBy: " ")
            )
        )
    }
    
    func testVerificationError() throws {
        let originalPhrase = "echo flat forget radio apology old until elite keep fine clock parent cereal ticket dutch whisper flock junior pet six uphold gorilla trend spare"
        let hdKey = try Ed25519HierachicalPrivateKey.fromRootSeed(rootSeed: try Mnemonic(phrase: originalPhrase.components(separatedBy: " ")).seed)

        // radio and forget are flipped - Mnenomics implementation detects words are transposed based on checksum validations
        let transposedWords = "echo flat radio forget apology old until elite keep fine clock parent cereal ticket dutch whisper flock junior pet six uphold gorilla trend spare"
        XCTAssertThrowsError(try Ed25519HierachicalPrivateKey.fromRootSeed(rootSeed: try Mnemonic(phrase: transposedWords.components(separatedBy: " ")).seed)) { error in
            XCTAssertEqual(error as! Mnemonic.Error, Mnemonic.Error.invalidMnemonic)
        }
       
        // change the word old to new (which is not a valid word)
        let wrongWords = "echo flat forget radio apology new until elite keep fine clock parent cereal ticket dutch whisper flock junior pet six uphold gorilla trend spare"
        XCTAssertThrowsError(try Ed25519HierachicalPrivateKey.fromRootSeed(rootSeed: try Mnemonic(phrase: wrongWords.components(separatedBy: " ")).seed)) { error in
            XCTAssertEqual(error as! Mnemonic.Error, Mnemonic.Error.invalidMnemonic)
        }
       
        // change forget to forged
        let incorrectSpelledWords = "echo flat forged radio apology old until elite keep fine clock parent cereal ticket dutch whisper flock junior pet six uphold gorilla trend spare"
        XCTAssertThrowsError(try Ed25519HierachicalPrivateKey.fromRootSeed(rootSeed: try Mnemonic(phrase: incorrectSpelledWords.components(separatedBy: " ")).seed)) { error in
            XCTAssertEqual(error as! Mnemonic.Error, Mnemonic.Error.invalidMnemonic)
        }
       
        // valid phrase for a different key
        let otherValidPhrase = "refuse hedgehog nerve insect silent sunset regret slush walnut illness visit slim advance mobile shrug initial grid topple inch okay bunker marriage bench chapter"
        let hdKey2 = try Ed25519HierachicalPrivateKey.fromRootSeed(rootSeed: try Mnemonic(phrase: otherValidPhrase.components(separatedBy: " ")).seed)
        XCTAssertNotEqual(hdKey.privateKey.rawRepresentation.toHexString(), hdKey2.privateKey.rawRepresentation.toHexString())
   }
    
    func testValidWords() throws {
        XCTAssertTrue(Wordlists.english.contains("zoo"))
        XCTAssertFalse(Wordlists.english.contains("zoom"))
        XCTAssertTrue(Wordlists.english.contains("forget"))
        XCTAssertFalse(Wordlists.english.contains("forged"))
    }
    
    func testBitcoinKey() throws {
        
        let seedPhrase = "bacon loop helmet quarter exist notice laundry auction rain bus vanish buyer drama icon response"
        let expectedXprv = "xprvA3HQivyehcyaqxxDcV3Niye157nbJKpuETYf6aZZup65XHNbyrXrkVZuT5T3i7bTsoCjTXnqWfjLxWdMUgDL3kTM4XftmSQnz7LP6RGiShr"
        let expectedXpub = "xpub6GGm8SWYXzXt4T2giWaP67ajd9d5hnYkbgUFtxyBU9d4Q5hkXPr7JHtPJN5dD6uNVXb7EEpdZeXvG5XwFVWhUj4Q2ufhYH38fuHK9ERTy3d"
        let expectedPubKey = "0318287a66643f9db1956c812c533bb3d6b22dce7955d7169d6f8ed39d4e96c909"
        
        let rootSeed = try Mnemonic(phrase: seedPhrase.components(separatedBy: " ")).seed

        let signingKey = try Secp256k1HierarchicalKey
            .fromRootSeed(rootSeed: rootSeed, derivationPath: Secp256k1HierarchicalKey.bitcoinDerivationPath)
            .derived(at: DerivationNode.notHardened(0))

        XCTAssertEqual(expectedXprv, signingKey.getBase58ExtendedPrivateKey())
        XCTAssertEqual(expectedXpub, signingKey.getBase58ExtendedPublicKey())
        XCTAssertEqual(expectedPubKey, signingKey.privateKey.getPublicKeyBytes().toHexString())
        
        let keyFromExtendedKey = try Secp256k1HierarchicalKey.fromBase58ExtendedKey(extendedKey: expectedXprv)
        XCTAssertEqual(signingKey.privateKey.raw, keyFromExtendedKey.privateKey.raw)
        XCTAssertEqual(signingKey.privateKey.chainCode, keyFromExtendedKey.privateKey.chainCode)
        XCTAssertEqual(signingKey.privateKey.fingerprint, keyFromExtendedKey.privateKey.fingerprint)
        XCTAssertEqual(signingKey.privateKey.index, keyFromExtendedKey.privateKey.index)
        
        XCTAssertEqual(keyFromExtendedKey.getBase58ExtendedPrivateKey(), expectedXprv)
        
        XCTAssertEqual(
            "xprvA4cB8k96tmXLGrVb8u68kA353rZ5XTn9m3S8EL76uU57PFYjpkzSdXxx8zmjbzKCDTvVzYrvphocPBxqMkKhoHXWoKdP1oGdSmM2MR4szeG",
            keyFromExtendedKey.derived(at: DerivationNode.notHardened(1)).getBase58ExtendedPrivateKey()
        )
        
        
    }
    
    func testBitcoinSigning() throws {
        let bitcoinExtendedPrivateKey = "tprv8igBmKYoTNej2GHV2ZvfQ3eJM9yAeDoMs8pTDqJLR1EzCHJc42QrxLGuh6Hh5b248yzeC5DAWyby76b9rbhL7L7GJuAeXY1k7yiYyjajcW4"
        let bitcoinKey = try Secp256k1HierarchicalKey
            .fromBase58ExtendedKey(extendedKey: bitcoinExtendedPrivateKey)
            .derived(at: DerivationNode.notHardened(0))

        let messagesToSign = [
            "OdGGt+Yh9Fp1wjHVGwpbmVJnjWOdFnZpeC+F9l+HG8g=",
            "AnxjVJFcoqK4y3URV/UMI4F9jIER5bb2cDI+TtkMtMc=",
            "m73uZw7PDXkA5VzKxDEqdT+AMT2vwGvVcjzlRyd4a6E="
        ]
        let knownGoodSignatures = [
            "MEQCIBiSprONqD6ejJ+DnFMBO4J/XuBB0+g1AZbsVhAwVvOxAiAzxIvPIbILK1T3ansYRN64F16OTfxVBV6r+W878BWWUg==",
            "MEQCIGrIRsSweu+vxPD7bf3cTQQeTKGK6dL3y0bhixPFLdGAAiAS5Ryvpch7KusXaAqMGkmkFt/IzgdpJ2LHTWzXSuPxOw==",
            "MEMCH19ac8Hpx+fKnzyZSxjFR6uRHnTgyYOa3J995/jAor0CIDJT47QNi9BdGOQBLSApVwAWYxNPlgamvrSbkn7i5uI1"
        ]
        for i in 0..<messagesToSign.count {
            XCTAssertEqual(knownGoodSignatures[i], try bitcoinKey.signData(message: Data(base64Encoded: messagesToSign[i])!).base64EncodedString())
            XCTAssertTrue(try bitcoinKey.verifySignature(Data(base64Encoded: knownGoodSignatures[i])!, message: Data(base64Encoded: messagesToSign[i])!))
        }
    }

    
}
