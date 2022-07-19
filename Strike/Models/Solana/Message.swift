//
//  Message2.swift
//  SolanaSwift
//
//  Created by Chung Tran on 02/04/2021.
//
import Foundation

struct Transaction {
    
    
    static func compileMessage(feePayer: PublicKey, recentBlockhash: String, instructions: [TransactionInstruction]) throws -> Message {
        // verify instructions
        guard instructions.count > 0 else {
            throw SolanaError.other("No instructions provided")
        }
        
        // programIds & accountMetas
        var programIds = [PublicKey]()
        var accountMetas = [Account.Meta]()
        
        for instruction in instructions {
            accountMetas.append(contentsOf: instruction.keys)
            if !programIds.contains(instruction.programId) {
                programIds.append(instruction.programId)
            }
        }
        
        for programId in programIds {
            accountMetas.append(
                .init(publicKey: programId, isSigner: false, isWritable: false)
            )
        }
        
        // sort accountMetas, first by signer, then by writable
        accountMetas.sort { (x, y) -> Bool in
            if x.isSigner != y.isSigner {return x.isSigner}
            if x.isWritable != y.isWritable {return x.isWritable}
            return false
        }
        
        // filterOut duplicate account metas, keeps writable one
        accountMetas = accountMetas.reduce([Account.Meta](), {result, accountMeta in
            var uniqueMetas = result
            if let index = uniqueMetas.firstIndex(where: {$0.publicKey == accountMeta.publicKey}) {
                // if accountMeta exists
                uniqueMetas[index].isWritable = uniqueMetas[index].isWritable || accountMeta.isWritable
            } else {
                uniqueMetas.append(accountMeta)
            }
            return uniqueMetas
        })
        
        // move fee payer to front
        accountMetas.removeAll(where: {$0.publicKey == feePayer})
        accountMetas.insert(
            Account.Meta(publicKey: feePayer, isSigner: true, isWritable: true),
            at: 0
        )
        

        // header
        var header = Message.Header()
        
        var signedKeys = [Account.Meta]()
        var unsignedKeys = [Account.Meta]()
        
        for accountMeta in accountMetas {
            // signed keys
            if accountMeta.isSigner {
                signedKeys.append(accountMeta)
                header.numRequiredSignatures += 1
                
                if !accountMeta.isWritable {
                    header.numReadonlySignedAccounts += 1
                }
            }
            
            // unsigned keys
            else {
                unsignedKeys.append(accountMeta)
                
                if !accountMeta.isWritable {
                    header.numReadonlyUnsignedAccounts += 1
                }
            }
        }
        
        accountMetas = signedKeys + unsignedKeys

        return Message(
            accountKeys: accountMetas,
            recentBlockhash: recentBlockhash,
            programInstructions: instructions
        )
    }
    
    
    struct Message {
        // MARK: - Constants
        private static let RECENT_BLOCK_HASH_LENGTH = 32

        // MARK: - Properties
        var accountKeys: [Account.Meta]
        var recentBlockhash: String
//        var instructions: [Transaction.Instruction]
        var programInstructions: [TransactionInstruction]

        func serialize() throws -> Data {
            // Header
            let header = encodeHeader()

            // Account keys
            let accountKeys = encodeAccountKeys()

            // RecentBlockHash
            let recentBlockhash = encodeRecentBlockhash()

            // Compiled instruction
            let compiledInstruction = try encodeInstructions()

            // Construct data
//            let bufferSize: Int =
//                Header.LENGTH // header
//                + keyCount.count // number of account keys
//                + Int(accountKeys.count) * PublicKey.LENGTH // account keys
//                + RECENT_BLOCK_HASH_LENGTH // recent block hash
//                + instructionsLength.count
//                + compiledInstructionsLength

            var data = Data(/*capacity: bufferSize*/)

            // Append data
            data.append(header)
            data.append(accountKeys)
            data.append(recentBlockhash)
            data.append(compiledInstruction)

            return data
        }

        private func encodeHeader() -> Data {
            var header = Header()
            for meta in accountKeys {
                if meta.isSigner {
                    // signed
                    header.numRequiredSignatures += 1

                    // signed & readonly
                    if !meta.isWritable {
                        header.numReadonlySignedAccounts += 1
                    }
                } else {
                    // unsigned & readonly
                    if !meta.isWritable {
                        header.numReadonlyUnsignedAccounts += 1
                    }
                }
            }
            return Data(header.bytes)
        }

        private func encodeAccountKeys() -> Data {
            // length
            let keyCount = encodeLength(accountKeys.count)

            // construct data
            var data = Data(capacity: keyCount.count + accountKeys.count * PublicKey.numberOfBytes)

            // sort
            let signedKeys = accountKeys.filter {$0.isSigner}
            let unsignedKeys = accountKeys.filter {!$0.isSigner}
            let accountKeys = signedKeys + unsignedKeys

            // append data
            data.append(keyCount)
            for meta in accountKeys {
                data.append(meta.publicKey.data)
            }
            return data
        }

        private func encodeRecentBlockhash() -> Data {
            Data(Base58.decode(recentBlockhash))
        }

        private func encodeInstructions() throws -> Data {
            var compiledInstructions = [CompiledInstruction]()

            for instruction in programInstructions {

                let keysSize = instruction.keys.count

                var keyIndices = Data()
                for i in 0..<keysSize {
                    let index = try accountKeys.index(ofElementWithPublicKey: instruction.keys[i].publicKey)
                    keyIndices.append(UInt8(index))
                }

                let compiledInstruction = CompiledInstruction(
                    programIdIndex: UInt8(try accountKeys.index(ofElementWithPublicKey: instruction.programId)),
                    keyIndicesCount: [UInt8](Data.encodeLength(keysSize)),
                    keyIndices: [UInt8](keyIndices),
                    dataLength: [UInt8](Data.encodeLength(instruction.data.count)),
                    data: instruction.data
                )

                compiledInstructions.append(compiledInstruction)
            }

            let instructionsLength = encodeLength(compiledInstructions.count)

            return instructionsLength + compiledInstructions.reduce(Data(), {$0 + $1.serializedData})
        }

        private func encodeLength(_ length: Int) -> Data {
            Data.encodeLength(length)
        }
    }
}

extension Transaction.Message {
    // MARK: - Nested type
    public struct Header: Decodable {
        static let LENGTH = 3
        // TODO:
        var numRequiredSignatures: UInt8 = 0
        var numReadonlySignedAccounts: UInt8 = 0
        var numReadonlyUnsignedAccounts: UInt8 = 0

        var bytes: [UInt8] {
            [numRequiredSignatures, numReadonlySignedAccounts, numReadonlyUnsignedAccounts]
        }
    }

    struct CompiledInstruction {
        let programIdIndex: UInt8
        let keyIndicesCount: [UInt8]
        let keyIndices: [UInt8]
        let dataLength: [UInt8]
        let data: [UInt8]

        var length: Int {
            1 + keyIndicesCount.count + keyIndices.count + dataLength.count + data.count
        }

        var serializedData: Data {
            Data([programIdIndex] + keyIndicesCount + keyIndices + dataLength + data)
        }
    }
}

public extension Data {
    var decodedLength: Int {
        var len = 0
        var size = 0
        var bytes = self
        while true {
            guard let elem = bytes.first else {break}
            bytes = bytes.dropFirst()
            len = len | ((Int(elem) & 0x7f) << (size * 7))
            size += 1
            if Int16(elem) & 0x80 == 0 {
                break
            }
        }
        return len
    }

    static func encodeLength(_ len: Int) -> Data {
        encodeLength(UInt(len))
    }

    private static func encodeLength(_ len: UInt) -> Data {
        var rem_len = len
        var bytes = Data()
        while true {
            var elem = rem_len & 0x7f
            rem_len = rem_len >> 7
            if rem_len == 0 {
                bytes.append(UInt8(elem))
                break
            } else {
                elem = elem | 0x80
                bytes.append(UInt8(elem))
            }
        }
        return bytes
    }
}

struct Account {
    struct Meta: Codable, CustomDebugStringConvertible {
        public let publicKey: PublicKey
        public var isSigner: Bool
        public var isWritable: Bool

        // MARK: - Decodable
        enum CodingKeys: String, CodingKey {
            case pubkey, signer, writable
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            publicKey = try PublicKey(string: try values.decode(String.self, forKey: .pubkey))
            isSigner = try values.decode(Bool.self, forKey: .signer)
            isWritable = try values.decode(Bool.self, forKey: .writable)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(publicKey.base58EncodedString, forKey: .pubkey)
            try container.encode(isSigner, forKey: .signer)
            try container.encode(isWritable, forKey: .writable)
        }

        // Initializers
        public init(publicKey: PublicKey, isSigner: Bool, isWritable: Bool) {
            self.publicKey = publicKey
            self.isSigner = isSigner
            self.isWritable = isWritable
        }

        public var debugDescription: String {
            "{\"publicKey\": \"\(publicKey.base58EncodedString)\", \"isSigner\": \(isSigner), \"isWritable\": \(isWritable)}"
        }
    }
}

extension Array where Element == Account.Meta {
    func index(ofElementWithPublicKey publicKey: PublicKey) throws -> Int {
        guard let index = firstIndex(where: {$0.publicKey == publicKey})
        else {throw SolanaError.other("Could not found accountIndex")}
        return index
    }
}


