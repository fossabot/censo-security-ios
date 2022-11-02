//
//  StrikeTestHelper.swift
//  StrikeTests
//
//  Created by Brendan Flood on 3/27/22.
//

import Foundation

import XCTest
@testable import Strike
import CryptoKit

extension StrikeTests {

    func getSignersUpdateRequestForApproval(nonceAccountAddresses: [String]) ->  SolanaApprovalRequestType {
        return
            .signersUpdate(
            SignersUpdate(
                slotUpdateType: SlotUpdateType.SetIfEmpty,
                signer: SlotSignerInfo(slotId: 2,
                                       value: SignerInfo(
                                        publicKey: "2XZHYvnhZGmgFB6TQyi3C1FYgeL9N2mK5c6rKfAFVJgg",
                                        name: "User 3",
                                        email: "user3@org1",
                                        nameHashIsEmpty: false)),
                signingData: SolanaSigningData(
                    feePayer: "87VXbkJsqdDvXYfDBtS4kW4TcFor7ogofZXbXjT7t7AU",
                    walletProgramId: "VbvBzjdJfGC5apNttzS4oi1wGsPFU4EdFw5ijZAHcun",
                    multisigOpAccountAddress: "2nf2bKZtao2hK6f1ke69vq2Qqyj8swg7Ny4MZfR4jxHW",
                    walletAddress: "FvFqGJZEd1BeR2WggMUZPR8zHCHVfqTaEgRUAzcbuB4x",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "HMCoXMD8MozBU8ZFDfGDwTkVpWK2txXwesHdmvRvY95e",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: Data(count: 32).base64EncodedString(),
                    walletGuidHash: "4NwP6vHH4z2gopFoMOWR2T+dilDDJuXWKmQt5ckS7Ko="
                )
            )
        )
    }

    func getSignersUpdateRequest(nonceAccountAddresses: [String]) ->  SolanaApprovalRequestType {
        return
            .signersUpdate(
            SignersUpdate(
                slotUpdateType: SlotUpdateType.SetIfEmpty,
                signer: SlotSignerInfo(slotId: 1,
                                       value: SignerInfo(
                                        publicKey: "8Mj26LQKUUVMUX7z8Qsvjpz2x6hMLFaER9axqHK4PvP7",
                                        name: "User 2",
                                        email: "user2@org1",
                                        nameHashIsEmpty: false)),
                signingData: SolanaSigningData(
                    feePayer: "87VXbkJsqdDvXYfDBtS4kW4TcFor7ogofZXbXjT7t7AU",
                    walletProgramId: "5JHcZTW5F1e5zWHb5zVWgi6pwbKuynRS3fyT7v48YEJZ",
                    multisigOpAccountAddress: "GjfqFH8T4BiL6pwtZxdq7BPZK7uaWJBKbooG4iQxSsaM",
                    walletAddress: "4B8ogHEgwh5CtnuCwyTXgxQjEfRgNcUpSTyhhtjKfL5Q",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "kwwyzySTUJHWBF64u15iwv8bMvcHTNmZzfEh9iDeC7j",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: Data(count: 32).base64EncodedString(),
                    walletGuidHash: "LZN57KM3swDiAbOZ1W0iwgGrJ2trzjaUGWX5Qc2zSK4="
                )
            )
        )
    }

    func getSignersUpdateApprovalRequest(nonceAccountAddresses: [String]) ->  ApprovalRequest {
        return getApprovalRequest(getSignersUpdateRequest(nonceAccountAddresses: nonceAccountAddresses))
    }
        
    func getSolanaWalletCreationRequest(nonceAccountAddresses: [String]) -> SolanaApprovalRequestType {
        return .walletCreation(
            WalletCreation(
                accountSlot: 0,
                accountInfo: AccountInfo(
                    name: "Account 1",
                    identifier: "c6055be1-a895-45a6-b0f3-fce261760b89",
                    accountType: AccountType.BalanceAccount,
                    address: nil,
                    chainName: Chain.solana
                ),
                approvalPolicy: ApprovalPolicy(
                    approvalsRequired: 1,
                    approvalTimeout: 3600000,
                    approvers: [SlotSignerInfo(slotId: 0, value: SignerInfo(
                        publicKey: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ",
                        name: "User 1",
                        email: "authorized1@org1",
                        nameHashIsEmpty: false
                    ))]
                ),
                whitelistEnabled: BooleanSetting.Off,
                dappsEnabled: BooleanSetting.Off,
                addressBookSlot: 1,
                signingData: SolanaSigningData(
                    feePayer: "87VXbkJsqdDvXYfDBtS4kW4TcFor7ogofZXbXjT7t7AU",
                    walletProgramId: "db4pdTHvA3XLBgKfwKzdx8DcNpHuWWn63t6u8kbYiuS",
                    multisigOpAccountAddress: "2DBQ368KgyPkmqd6fKsQpmpMhBTDTuW6wWESbxDs5otz",
                    walletAddress: "JCd6uutAtgsbxDfM54ss4TyeG6kakvSfdxJwjBTjkPLh",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: Data(count: 32).base64EncodedString(),
                    walletGuidHash: Data(count: 32).base64EncodedString()
                )
            )
        )
    }
    
    func getBitcoinWalletCreationRequest() -> SolanaApprovalRequestType {
        return .walletCreation(
            WalletCreation(
                accountSlot: 0,
                accountInfo: AccountInfo(
                    name: "Account 1",
                    identifier: "c6055be1-a895-45a6-b0f3-fce261760b89",
                    accountType: AccountType.BalanceAccount,
                    address: nil,
                    chainName: Chain.bitcoin
                ),
                approvalPolicy: ApprovalPolicy(
                    approvalsRequired: 1,
                    approvalTimeout: 3600000,
                    approvers: [SlotSignerInfo(slotId: 0, value: SignerInfo(
                        publicKey: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ",
                        name: "User 1",
                        email: "authorized1@org1",
                        nameHashIsEmpty: false
                    ))]
                ),
                whitelistEnabled: BooleanSetting.Off,
                dappsEnabled: BooleanSetting.Off,
                addressBookSlot: 1,
                signingData: nil
            )
        )
    }
    
    func getEthereumWalletCreationRequest() -> SolanaApprovalRequestType {
        return .walletCreation(
            WalletCreation(
                accountSlot: 0,
                accountInfo: AccountInfo(
                    name: "Account 1",
                    identifier: "c6055be1-a895-45a6-b0f3-fce261760b89",
                    accountType: AccountType.BalanceAccount,
                    address: nil,
                    chainName: Chain.ethereum
                ),
                approvalPolicy: ApprovalPolicy(
                    approvalsRequired: 1,
                    approvalTimeout: 3600000,
                    approvers: [SlotSignerInfo(slotId: 0, value: SignerInfo(
                        publicKey: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ",
                        name: "User 1",
                        email: "authorized1@org1",
                        nameHashIsEmpty: false
                    ))]
                ),
                whitelistEnabled: BooleanSetting.Off,
                dappsEnabled: BooleanSetting.Off,
                addressBookSlot: 1,
                signingData: nil
            )
        )
    }
 
    func getSolWithdrawalRequest(nonceAccountAddresses: [String]) -> SolanaApprovalRequestType {
        return .withdrawalRequest(
            WithdrawalRequest(
                account: AccountInfo(
                    name: "Account 1",
                    identifier: "c6055be1-a895-45a6-b0f3-fce261760b89",
                    accountType: AccountType.BalanceAccount,
                    address: "oRYGxVHXEqpLaH9QWxX8yRMzLsmPRXyfNmop2QrPQKY",
                    chainName: nil
                ),
                symbolAndAmountInfo: SymbolAndAmountInfo(
                    symbolInfo: SymbolInfo(
                        symbol: "SOL",
                        symbolDescription: "Solana",
                        tokenMintAddress: "11111111111111111111111111111111",
                        imageUrl: nil,
                        nftMetadata: nil
                    ),
                    amount: "0.500000000",
                    usdEquivalent: "17.75"
                ),
                destination: DestinationAddress(
                    name: "My External Sol address",
                    subName: nil,
                    address: "2DQz5vWgs1PKxPDd9YaYKoemgFriRJqoFRniAQ7Wtuva",
                    tag: nil
                ),
                signingData: SigningData.solana(SolanaSigningData(
                    feePayer: "87VXbkJsqdDvXYfDBtS4kW4TcFor7ogofZXbXjT7t7AU",
                    walletProgramId: "db4pdTHvA3XLBgKfwKzdx8DcNpHuWWn63t6u8kbYiuS",
                    multisigOpAccountAddress: "9NDFtaczqouZ9SGTfd489EfN3KvMQgrAjpuu4QEr9Kys",
                    walletAddress: "JCd6uutAtgsbxDfM54ss4TyeG6kakvSfdxJwjBTjkPLh",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: Data(count: 32).base64EncodedString(),
                    walletGuidHash: Data(count: 32).base64EncodedString()
                ))
            )
        )
    }

    
    func getSplWithdrawalRequest(nonceAccountAddresses: [String]) -> SolanaApprovalRequestType {
        return .withdrawalRequest(
            WithdrawalRequest(
                account: AccountInfo(
                    name: "Account 1",
                    identifier: "5fb4556a-6de5-4a80-ac0e-6def9826384f",
                    accountType: AccountType.BalanceAccount,
                    address: "HT8kqgLxH5BsyA6Ah3oaAKG8SNAgzgRNH4uMfcAnUXTZ",
                    chainName: nil
                ),
                symbolAndAmountInfo: SymbolAndAmountInfo(
                    symbolInfo: SymbolInfo(
                        symbol: "soTEST",
                        symbolDescription: "Test SPL token",
                        tokenMintAddress: "AZ6C941cFEv7EWUsPeeYYEK278Lw5wK4AVR6Mngdt9fr",
                        imageUrl: nil,
                        nftMetadata: nil
                    ),
                    amount: "0.000500",
                    usdEquivalent: nil
                ),
                destination: DestinationAddress(
                    name: "Org1 Sol Wallet",
                    subName: nil,
                    address: "7DhLZAT5buGyXpjpfRNKaHc1imjJaDzCXXTdM59JHrpQ",
                    tag: nil
                ),
                signingData: SigningData.solana(SolanaSigningData(
                    feePayer: "FM36ah2bH8nQWJNPCRzu7R69gE5o6UhujqJFtDpWN5as",
                    walletProgramId: "zeZ7E8F6UaNYy3ry3Mt6MGUSr679oTKV8tzXVe5B4bP",
                    multisigOpAccountAddress: "6UcFAr9rqGfFEtLxnYdW6QjeRor3aej5akLpYpXUkPWX",
                    walletAddress: "7fvoSJ6iNAyTFvBDuAWuciXWYiyUBtJfCUswZF3YGbUN",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: Data(count: 32).base64EncodedString(),
                    walletGuidHash: Data(count: 32).base64EncodedString()
                ))
            )
        )
    }


    func getConversionRequest(nonceAccountAddresses: [String]) -> SolanaApprovalRequestType {
        return .conversionRequest(
            ConversionRequest(
                account: AccountInfo(
                    name: "Account 1",
                    identifier: "9826889c-df77-4c5b-b4ad-9bde935e6c52",
                    accountType: AccountType.BalanceAccount,
                    address: "F8MQFSzgGtddamGjNNoFuUfrZNZkV84icnXwyMVo7Aa3",
                    chainName: nil
                ),
                symbolAndAmountInfo: SymbolAndAmountInfo(
                    symbolInfo: SymbolInfo(
                        symbol: "USDC",
                        symbolDescription: "USD Coin",
                        tokenMintAddress: "ALmJ9wWY2o1FiLcSDuvHN3xH5UHLkYsVbz2JWD37MuUY",
                        imageUrl: nil,
                        nftMetadata: nil
                    ),
                    amount: "500.000000",
                    usdEquivalent: "500.00"
                ),
                destination: DestinationAddress(
                    name: "USDC Redemption Address",
                    subName: nil,
                    address: "Bt4cfS3fhtbCiB3uDXDRvft6SCVbHCH7Pz7kh66tzzKA",
                    tag: nil
                ),
                destinationSymbolInfo: SymbolInfo(
                    symbol: "USD",
                    symbolDescription: "US Dollar",
                    tokenMintAddress: "11111111111111111111111111111111",
                    imageUrl: nil,
                    nftMetadata: nil
                ),
                signingData: SolanaSigningData(
                    feePayer: "FBiyhqgyrv6iRejRgL9tDYxB2jtEB4RH9pnPK2CN5J4m",
                    walletProgramId: "CH2nLW24j2Wd1geFGSKkJmbAz1KLhACR9RRD1wHgCH74",
                    multisigOpAccountAddress: "11111111111111111111111111111111",
                    walletAddress: "2sGiNkpwYod6c1Wcd6H1ycd85KwykMfb8ZCt7t3XEp4h",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: Data(count: 32).base64EncodedString(),
                    walletGuidHash: Data(count: 32).base64EncodedString()
                )
            )
        )
    }
    
    func getWrapConversionRequest(nonceAccountAddresses: [String]) -> SolanaApprovalRequestType {
        return .wrapConversionRequest(
            WrapConversionRequest(
                account: AccountInfo(
                    name: "Account 1",
                    identifier: "707399af-d2e7-4668-805f-bb5b970d8a9b",
                    accountType: AccountType.BalanceAccount,
                    address: "GQcSdA3q2Wokxc7V9UschxddDanMnLzhqq9Aji21hovQ",
                    chainName: nil
                ),
                symbolAndAmountInfo: SymbolAndAmountInfo(
                    symbolInfo: SymbolInfo(
                        symbol: "SOL",
                        symbolDescription: "Solana",
                        tokenMintAddress: "11111111111111111111111111111111",
                        imageUrl: nil,
                        nftMetadata: nil
                    ),
                    amount: "0.500000000",
                    usdEquivalent: "44.39"
                ),
                destinationSymbolInfo: SymbolInfo(
                    symbol: "wSOL",
                    symbolDescription: "Wrapped SOL",
                    tokenMintAddress: "11111111111111111111111111111111",
                    imageUrl: nil,
                    nftMetadata: nil
                ),
                signingData: SolanaSigningData(
                    feePayer: "87VXbkJsqdDvXYfDBtS4kW4TcFor7ogofZXbXjT7t7AU",
                    walletProgramId: "8UBQs57hD4ZRJ4gdAmPDTk9EJZAN56sRtoZzWAo2jWpj",
                    multisigOpAccountAddress: "11111111111111111111111111111111",
                    walletAddress: "4mDU4xbVcgiQx1VB45PAFXisNiNkFAhmp4s2aGL8DvA8",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "ECiEjQXPJ792V4Vrs7gozNrGVVshtxN9o9q9RDTqPSeK",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
                    walletGuidHash: "oiAuZm28uacpX+tnS+Ntx8Kve3X9ELCJsXYFHEhFdDM="
                )
            )
        )
    }
    
    func getUnwrapConversionRequest(nonceAccountAddresses: [String]) -> SolanaApprovalRequestType {
        return .wrapConversionRequest(
            WrapConversionRequest(
                account: AccountInfo(
                    name: "Account 1",
                    identifier: "c2a6711d-8430-429f-816a-876eb62dd19e",
                    accountType: AccountType.BalanceAccount,
                    address: "7dMB51drmhKy9qQ8GjFPsaRDnadGCvn4iLWedqajbmUg",
                    chainName: nil
                ),
                symbolAndAmountInfo: SymbolAndAmountInfo(
                    symbolInfo: SymbolInfo(
                        symbol: "wSOL",
                        symbolDescription: "Wrapped SOL",
                        tokenMintAddress: "11111111111111111111111111111111",
                        imageUrl: nil,
                        nftMetadata: nil
                    ),
                    amount: "0.300000000",
                    usdEquivalent: "26.63"
                ),
                destinationSymbolInfo: SymbolInfo(
                    symbol: "SOL",
                    symbolDescription: "Solana",
                    tokenMintAddress: "11111111111111111111111111111111",
                    imageUrl: nil,
                    nftMetadata: nil
                ),
                signingData: SolanaSigningData(
                    feePayer: "87VXbkJsqdDvXYfDBtS4kW4TcFor7ogofZXbXjT7t7AU",
                    walletProgramId: "8S1mgAomg5mcJ6rC38xHMMJyFKTHxQc2dHgNrmQKzAz",
                    multisigOpAccountAddress: "11111111111111111111111111111111",
                    walletAddress: "HZmqaRJWQxB6B4DXCBmY5W8xjL2Wn5Q6rGHtajxUDbra",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "3S3WAHv5h7gyEVTPQRuz6sf8poKM439zr14pHF43MtLK",
                    strikeFeeAmount: 2039280,
                    feeAccountGuidHash: "Oe1VO8ObkbQ2jHnzOD6tIGQNkX/sExJpdGOksGK47VU=",
                    walletGuidHash: "/Fz5hXppVfCrsvkgU8zXy5e3IO99xOmbQJuF7DUkHfw="
                )
            )
        )
    }
    
    func getAddAddressBookEntry(nonceAccountAddresses: [String]) -> SolanaApprovalRequestType {
        return .addressBookUpdate(
            AddressBookUpdate(
                change: .add,
                entry: SlotDestinationInfo(
                    slotId: 0,
                    value: DestinationAddress(name: "My External Sol address", subName: nil, address: "2DQz5vWgs1PKxPDd9YaYKoemgFriRJqoFRniAQ7Wtuva", tag: nil)
                ),
                signingData: SolanaSigningData(
                    feePayer: "87VXbkJsqdDvXYfDBtS4kW4TcFor7ogofZXbXjT7t7AU",
                    walletProgramId: "db4pdTHvA3XLBgKfwKzdx8DcNpHuWWn63t6u8kbYiuS",
                    multisigOpAccountAddress: "Dpt714om7J3B3f1ygptgoEnFvHo3aiXjeLPP7TqjHJhq",
                    walletAddress: "JCd6uutAtgsbxDfM54ss4TyeG6kakvSfdxJwjBTjkPLh",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: Data(count: 32).base64EncodedString(),
                    walletGuidHash: Data(count: 32).base64EncodedString()
                ))
        )
    }
    
    func getAddDAppBookEntry(nonceAccountAddresses: [String]) -> SolanaApprovalRequestType {
        return .dAppBookUpdate(
            DAppBookUpdate(
                entriesToAdd: [
                    SlotDAppInfo(
                        slotId: 0,
                        value: SolanaDApp(address: "GNGhSWWVNhXAy4fQgfAoQejJpGAxVaE4bdJjdb6iXRjK", name: "DApp", logo: "icon")
                    )
                ],
                entriesToRemove: [],
                signingData: SolanaSigningData(
                    feePayer: "FM36ah2bH8nQWJNPCRzu7R69gE5o6UhujqJFtDpWN5as",
                    walletProgramId: "3Nh3QsaXKbTbLM1BLsD4dhT4zeHTPaVbZX3eN3Yg1G2w",
                    multisigOpAccountAddress: "Hn2CJuYyyB2H3wwmdHPy1Aun2Jkye3MCSVajzUvw55A9",
                    walletAddress: "Re4dLGch8a1G98PeRtpHa5ApS6Gnik444CqB5BQ8rY1",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: Data(count: 32).base64EncodedString(),
                    walletGuidHash: Data(count: 32).base64EncodedString()
                ))
        )
    }
    
    func getBalanceAccountSettingsUpdate(nonceAccountAddresses: [String]) -> SolanaApprovalRequestType {
        return .balanceAccountSettingsUpdate(
            BalanceAccountSettingsUpdate(
                account: AccountInfo(
                    name: "Account 1",
                    identifier: "c6055be1-a895-45a6-b0f3-fce261760b89",
                    accountType: AccountType.BalanceAccount,
                    address: "oRYGxVHXEqpLaH9QWxX8yRMzLsmPRXyfNmop2QrPQKY",
                    chainName: nil
                ),
                change: .whitelistEnabled(true),
                signingData: SolanaSigningData(
                    feePayer: "87VXbkJsqdDvXYfDBtS4kW4TcFor7ogofZXbXjT7t7AU",
                    walletProgramId: "db4pdTHvA3XLBgKfwKzdx8DcNpHuWWn63t6u8kbYiuS",
                    multisigOpAccountAddress: "Dp4oaRWRtBxQdf5Lg2zti3TCjsUsxv4rUBgtf2HSQnVb",
                    walletAddress: "JCd6uutAtgsbxDfM54ss4TyeG6kakvSfdxJwjBTjkPLh",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: Data(count: 32).base64EncodedString(),
                    walletGuidHash: Data(count: 32).base64EncodedString()
                ))
        )
    }
    
    func getRemoveDAppBookEntry(nonceAccountAddresses: [String]) -> SolanaApprovalRequestType {
        return .dAppBookUpdate(
            DAppBookUpdate(
                entriesToAdd: [],
                entriesToRemove: [
                    SlotDAppInfo(
                        slotId: 0,
                        value: SolanaDApp(address: "GNGhSWWVNhXAy4fQgfAoQejJpGAxVaE4bdJjdb6iXRjK", name: "DApp", logo: "icon")
                    )
                ],
                signingData: SolanaSigningData(
                    feePayer: "FM36ah2bH8nQWJNPCRzu7R69gE5o6UhujqJFtDpWN5as",
                    walletProgramId: "3Nh3QsaXKbTbLM1BLsD4dhT4zeHTPaVbZX3eN3Yg1G2w",
                    multisigOpAccountAddress: "9CfoFci2agjCJ7bWqfgKEFSAc5zB6UR63MrK61nRaJzm",
                    walletAddress: "Re4dLGch8a1G98PeRtpHa5ApS6Gnik444CqB5BQ8rY1",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: Data(count: 32).base64EncodedString(),
                    walletGuidHash: Data(count: 32).base64EncodedString()
                ))
        )
    }
    
    func getWalletConfigPolicyUpdate(nonceAccountAddresses: [String]) -> SolanaApprovalRequestType {
        return .walletConfigPolicyUpdate(
            WalletConfigPolicyUpdate(
                approvalPolicy: ApprovalPolicy(
                    approvalsRequired: 2,
                    approvalTimeout: 18000000,
                    approvers: [
                        SlotSignerInfo(
                            slotId: 0,
                            value: SignerInfo(publicKey: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ", name: "User 1", email: "authorized1@org1", nameHashIsEmpty: false)
                        ),
                        SlotSignerInfo(
                            slotId: 1,
                            value: SignerInfo(publicKey: "7AH35qStXtrUgRkmqDmhjufNHjF74R1A9cCKT3C3HaAR", name: "User 2", email: "user2@org1", nameHashIsEmpty: false)
                        )
                    ]),
                signingData: SolanaSigningData(
                    feePayer: "87VXbkJsqdDvXYfDBtS4kW4TcFor7ogofZXbXjT7t7AU",
                    walletProgramId: "db4pdTHvA3XLBgKfwKzdx8DcNpHuWWn63t6u8kbYiuS",
                    multisigOpAccountAddress: "F6iUTdJDE4vnTgBanCtBgtoNHag57Uaut82xATGVVps3",
                    walletAddress: "JCd6uutAtgsbxDfM54ss4TyeG6kakvSfdxJwjBTjkPLh",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: Data(count: 32).base64EncodedString(),
                    walletGuidHash: Data(count: 32).base64EncodedString()
                ))
        )
    }
    
    func getBalanceAccountPolicyUpdate(nonceAccountAddresses: [String]) -> SolanaApprovalRequestType {
        return .balanceAccountPolicyUpdate(
            BalanceAccountPolicyUpdate(
                accountInfo: AccountInfo(
                    name: "Account 1",
                    identifier: "1ac4a7fc-d2f8-4c32-8707-7496ee958933",
                    accountType: AccountType.BalanceAccount,
                    address: "5743aqK2n9xnTSmFcbzTmfpdtcNeWdJsCxTxrCcNXUFH",
                    chainName: nil
                ),
                approvalPolicy: ApprovalPolicy(
                    approvalsRequired: 2,
                    approvalTimeout: 3600000,
                    approvers: [
                        SlotSignerInfo(
                            slotId: 0,
                            value: SignerInfo(publicKey: "4q8ApWsB3rSW2HPFwc1aWmGgcBMfj7tSKBbb5sBGAB6h", name: "User 1", email: "authorized1@org1", nameHashIsEmpty: false)
                        ),
                        SlotSignerInfo(
                            slotId: 1,
                            value: SignerInfo(publicKey: "CDrdR8xX8t83eXxB2ESuHp9AxkiJkUuKnD98zyDfMtrG", name: "User 2", email: "user2@org1", nameHashIsEmpty: false)
                        ),
                    ]
                ),
                signingData: SolanaSigningData(
                    feePayer: "FM36ah2bH8nQWJNPCRzu7R69gE5o6UhujqJFtDpWN5as",
                    walletProgramId: "8pPAcjFSByreFRnRm5YyAdBP2LfiNnWBtBzHtRDcJpUA",
                    multisigOpAccountAddress: "DbdTEwihgEYJYAgXBKEqQGknGyHsRnxE5coeZaVS4T9y",
                    walletAddress: "ECzeaMTMBXYXXfVM53n5iPepf8749QUqEzjW8jxefGhh",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: Data(count: 32).base64EncodedString(),
                    walletGuidHash: Data(count: 32).base64EncodedString()
                ))
        )
    }
    
    func getBalanceAccountNameUpdate(nonceAccountAddresses: [String]) -> SolanaApprovalRequestType {
        return .balanceAccountNameUpdate(
            BalanceAccountNameUpdate(
                accountInfo: AccountInfo(
                    name: "Account 1",
                    identifier: "b645a5d9-227f-4a9f-9331-52af64bf1989",
                    accountType: AccountType.BalanceAccount,
                    address: "DcvZ2k6ygvvu2Z5ihrSxRZL7bHJ38gPRgpCie8GzztTP",
                    chainName: nil
                ),
                newAccountName: "New Name",
                signingData: SolanaSigningData(
                    feePayer: "FM36ah2bH8nQWJNPCRzu7R69gE5o6UhujqJFtDpWN5as",
                    walletProgramId: "7kNPVcK2cpyaZsLsqmhZbjcbt433vYUckH1PM5gZeJ1L",
                    multisigOpAccountAddress: "7DY87mHHiSSyxFBbhCYbTpQE5M4Jk9Z9hymJ7UzL3sPm",
                    walletAddress: "4XaqL4MtTUDrncTGBqvTC9ketf8WVqrUocDkYhKAnDju",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: Data(count: 32).base64EncodedString(),
                    walletGuidHash: Data(count: 32).base64EncodedString()
                ))
        )
    }
    
    func getBalanceAccountAddressWhitelistUpdate(nonceAccountAddresses: [String]) -> SolanaApprovalRequestType {
        return .balanceAccountAddressWhitelistUpdate(
            BalanceAccountAddressWhitelistUpdate(
                accountInfo: AccountInfo(
                    name: "Account 1",
                    identifier: "4d2eecc1-cbe1-4c36-a4ae-1f777a739eb3",
                    accountType: AccountType.BalanceAccount,
                    address: "HvZFxso1tq9FLD1Gh2ACGNsR5pQBgjVC8uo21Cc9ytzg",
                    chainName: nil
                ),
                destinations: [
                    SlotDestinationInfo(
                        slotId: 1,
                        value: DestinationAddress(name: "My External Sol address 1", subName: nil, address: "AXX2TNxGhW2M3GpQPuWVuqmyAvQFVpyZD2dvR9gRiMRQ", tag: nil)
                    ),
                    SlotDestinationInfo(
                        slotId: 2,
                        value: DestinationAddress(name: "My External Sol address 2", subName: nil, address: "2db8ovVF6iXTaPQAhJe3frG46iNLF5Ny7ZipGKDomiTh", tag: nil)
                    )
                ],
                signingData: SolanaSigningData(
                    feePayer: "FM36ah2bH8nQWJNPCRzu7R69gE5o6UhujqJFtDpWN5as",
                    walletProgramId: "9LM4sYmMHk1VDcFpA8ezPeL8GtEVR5T51Qxcksrf4VX2",
                    multisigOpAccountAddress: "71S5qEAD3DMn7QY9fdb2uR1TV7kiAfcAqNHfQfyFUSME",
                    walletAddress: "AoEAvW2TvZYmy2WbmqN4nXdJT8o21RbJP6xNK2yR4of",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "3wKxhgiogoCaA2uxPYeH7cy3cG4hxRPogrPmDPLS54iZ",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: Data(count: 32).base64EncodedString(),
                    walletGuidHash: Data(count: 32).base64EncodedString()
                ))
        )
    }
    
    func getDAppTransactionRequest(nonceAccountAddresses: [String]) -> SolanaApprovalRequestType {
        return .dAppTransactionRequest(
            DAppTransactionRequest(
                account: AccountInfo(
                    name: "Account 1",
                    identifier: "f8d0a964-ea88-4843-973a-70e3a6ff8ab8",
                    accountType: AccountType.BalanceAccount,
                    address: "BRZxhTAUTwMokJyCMpuJcGtNdi8j8hApkwDWserqRFKr",
                    chainName: nil
                ),
                dappInfo: SolanaDApp(
                    address: "H2ZSeYCg4MwnCYh73biZJfwMSJ6KuugoH8JLf775cUns",
                    name: "DApp Name",
                    logo: "dapp-icon"
                ),
                balanceChanges: [],
                instructions: [
                    SolanaInstructionChunk(
                        offset: 0,
                        instructionData: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAMfbXr9Pd04d9oxuffFREfSADbnRIPEpVn6V8fj2rrdmAGa4BO3DrDz6LyXzXydHrFWh2+J/9ZlPFdeiuHbyV8P3QwAAgAAAADC6wsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAO9DFnzyLMsRmbgWH6JSH00UGHDt6bU14c2amFy43OtpgGa4BO3DrDz6LyXzXydHrFWh2+J/9ZlPFdeiuHbyV8P3QwAAgAAAADC6wsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAMkSqNHZ0rdcs4p7lXiRTF5mdcdy2a5YKT6j6+BzOGthQGa4BO3DrDz6LyXzXydHrFWh2+J/9ZlPFdeiuHbyV8P3QwAAgAAAADC6wsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAMv6SewjB9Bp/SAwlD3Dp3rVnnZqhlAFfBk8YNOpmSmbgGa4BO3DrDz6LyXzXydHrFWh2+J/9ZlPFdeiuHbyV8P3QwAAgAAAADC6wsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAANsBX+mLaLauW1bAZ+zXt5Z8/XY7ehn5ra8f6XKuuomsAGa4BO3DrDz6LyXzXydHrFWh2+J/9ZlPFdeiuHbyV8P3QwAAgAAAADC6wsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAM8Sd9NN2/+E90TCtcvBH4m11ETLdINd++tdjWUYZWUIwGa4BO3DrDz6LyXzXydHrFWh2+J/9ZlPFdeiuHbyV8P3QwAAgAAAADC6wsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAM6Da5ybuajCBKiBb85gQGHPCHZktkOJYZwT+BQHm5N5wGa4BO3DrDz6LyXzXydHrFWh2+J/9ZlPFdeiuHbyV8P3QwAAgA="
                    ),
                    SolanaInstructionChunk(
                        offset: 788,
                        instructionData: "AAAAwusLAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgADPa0Joq3Q2jHq6IeVnzS6oclt1ixZHlI7BKopyvdi8WwBmuATtw6w8+i8l818nR6xVodvif/WZTxXXorh28lfD90MAAIAAAAAwusLAAAAAA=="
                    )
                ],
                signingData: SolanaSigningData(
                    feePayer: "87VXbkJsqdDvXYfDBtS4kW4TcFor7ogofZXbXjT7t7AU",
                    walletProgramId: "5VouXXXz6WnRT2hGAeKqSoiqgdYMs5cAhtobuUh54AkS",
                    multisigOpAccountAddress: "Az1ZYXQYk1CraDLgLF72ge7bLd8k6kn4GWjPqiXco88t",
                    walletAddress: "GrdFiFNc6xC7fzC8ejcotE3uxPm8UTpndNWiEg4kALKW",
                    nonceAccountAddresses: nonceAccountAddresses,
                    nonceAccountAddressesSlot: 2256,
                    initiator: "6f51NkToPKgK2AY6GGf7scdbwXpZGNmkx6wvCdp9rQPW",
                    strikeFeeAmount: 0,
                    feeAccountGuidHash: Data(count: 32).base64EncodedString(),
                    walletGuidHash: "6ETtMeamm1fdYpXyezvfQqisy8nFFEDocw/HGyFFCUM="
                )
            )
        )
    }
    
    func getLoginApproval(_ jwtToken: String, email: String, name: String) -> SolanaApprovalRequestType {
        return .loginApproval(LoginApproval(jwtToken: jwtToken, email: email, name: name))
    }
    
    
    func getApprovalRequest(_ requestType: SolanaApprovalRequestType) -> ApprovalRequest {
        return ApprovalRequest(
            id: "1",
            submitterName: "",
            submitterEmail: "",
            submitDate: Date(),
            approvalTimeoutInSeconds: 1000,
            numberOfDispositionsRequired: 1,
            numberOfApprovalsReceived: 1,
            numberOfDeniesReceived: 1,
            vaultName: "Test Vault",
            details: .approval(requestType)
        )
    }

    func getWalletInitiationRequest(_ requestType: SolanaApprovalRequestType, initiation: MultisigOpInitiation) -> ApprovalRequest {
        return ApprovalRequest(
            id: "1",
            submitterName: "",
            submitterEmail: "",
            submitDate: Date(),
            approvalTimeoutInSeconds: 1000,
            numberOfDispositionsRequired: 1,
            numberOfApprovalsReceived: 1,
            numberOfDeniesReceived: 1,
            vaultName: "Test Vault",
            details: .multisigOpInitiation(initiation, requestType: requestType)
        )
    }
    
    func getOpAccountCreationInfo(accountSize: UInt64 = 952, minBalanceForRentExemption: UInt64 = 7516800) -> MultisigAccountCreationInfo {
        return MultisigAccountCreationInfo(
            accountSize: accountSize,
            minBalanceForRentExemption: minBalanceForRentExemption
        )
    }
}

extension String {
    enum ExtendedEncoding {
        case hexadecimal
    }

    func data(using encoding:ExtendedEncoding) -> Data? {
        switch encoding {
        case .hexadecimal:
            let hexStr = self.dropFirst(self.hasPrefix("0x") ? 2 : 0)

            var newData = Data(capacity: hexStr.count/2)

            var indexIsEven = true
            for i in hexStr.indices {
                if indexIsEven {
                    let byteRange = i...hexStr.index(after: i)
                    guard let byte = UInt8(hexStr[byteRange], radix: 16) else { return nil }
                    newData.append(byte)
                }
                indexIsEven.toggle()
            }
            return newData
        }
    }

}
