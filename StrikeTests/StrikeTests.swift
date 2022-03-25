//
//  StrikeTests.swift
//  StrikeTests
//
//  Created by Donald Ness on 12/23/20.
//

import XCTest
@testable import Strike

class StrikeTests: XCTestCase {
    
    func testSignersUpdateSerializedOp() throws {
        let approvalRequest = StrikeApi.ApprovalDispositionRequest(
            disposition: .Approve,
            request: getSignersUpdateRequest(),
            blockhash: getRecentBlockhash(),
            email: "dont care"
        )
        XCTAssertEqual(try approvalRequest.opHashData.toHexString(),
                       "05d79ee6b8ae98d572459d5d6572f088a8f6b1f40655eee8c981056b205e41a37500010156b088482c6882a3def445509a410c837a27476140df0c0da4be446071000e")
    }
    
    func testBalanceAccountCreationSerializedOp() throws {
        let approvalRequest = StrikeApi.ApprovalDispositionRequest(
            disposition: .Approve,
            request: getBalanceAccountCreationRequest(),
            blockhash: getRecentBlockhash(),
            email: "dont care"
        )
        XCTAssertEqual(try approvalRequest.opHashData.toHexString(),
                       "01d79ee6b8ae98d572459d5d6572f088a8f6b1f40655eee8c981056b205e41a375c157f7ceafefee71dc6ca5bbfdfe3d631686ceedc0d820acb1865fc149710ba600b94e0c79c1fb7db6ff3380f8bd8f09376fb8f87c488f98ec920164e1e3a7417101100e00000000000001003f63cead256ccb1638c9b4e41a0f9df567d1d6fec52018b993d64381528f3b45000000")
    }
    
    
    private func getSignersUpdateRequest() ->  WalletApprovalRequest {
        return getWalletApprovalRequest(requestType: .signersUpdate(SignersUpdate(
                slotUpdateType: SlotUpdateType.SetIfEmpty,
                signer: SlotSignerInfo(slotId: 1,
                                       value: SignerInfo(
                                        publicKey: "6E5S1pMfe7DfBwYp2KmmYvTup2hduP385dhhoexX8i9",
                                        name: "User 2",
                                        email: "user2@org1")),
                signingData: SolanaSigningData(
                    feePayer: "8UT5JS7vVcGLBHQe19Q5EK6aFA2CYnFG8a5C4dkrTL2B",
                    walletProgramId: "JAbzU4jwUMn92xhZcAX4M6JANEigzVMKKJqy6pA1cNBT",
                    multisigOpAccountAddress: "Hx9JnkPHioA9eu92y7jho1TxNaBCHYbw8zaSxvkGXSdD",
                    walletAddress: "FWhBukWcdXaMqZhJMvAAEH6PH81nV6JSpBEmwdvWgUjW"))
                )
        )
    }
    
    private func getBalanceAccountCreationRequest() ->  WalletApprovalRequest {
        return getWalletApprovalRequest(requestType: .balanceAccountCreation(BalanceAccountCreation(
                accountSlot: 0,
                accountInfo: AccountInfo(
                    name: "Account 1",
                    identifier: "849e19b2-e3ef-4700-97c1-cfdf0c75f7cf",
                    accountType: AccountType.BalanceAccount,
                    address: nil
                ),
                approvalsRequired: 1,
                approvalTimeout: 3600000,
                approvers: [SlotSignerInfo(slotId: 0, value: SignerInfo(
                    publicKey: "5GSxPr4NBQxGq9v3mXBMq9r2ymxp7HD6HabFdUWVCg7N",
                    name: "User 1",
                    email: "authorized1@org1"
                ))],
                whitelistEnabled: BooleanSetting.Off,
                dappsEnabled: BooleanSetting.Off,
                addressBookSlot: 0,
                signingData: SolanaSigningData(
                    feePayer: "8UT5JS7vVcGLBHQe19Q5EK6aFA2CYnFG8a5C4dkrTL2B",
                    walletProgramId: "JAbzU4jwUMn92xhZcAX4M6JANEigzVMKKJqy6pA1cNBT",
                    multisigOpAccountAddress: "58AHk21kCbW2oVe8s44pgbYdP6GwTtDDMokrhXDpaS4k",
                    walletAddress: "FWhBukWcdXaMqZhJMvAAEH6PH81nV6JSpBEmwdvWgUjW"))
                )
            )
    }
    
    func getWalletApprovalRequest(requestType: SolanaApprovalRequestType) -> WalletApprovalRequest {
        return WalletApprovalRequest(
            id: "1",
            walletType: WalletType.Solana,
            submitterName: "",
            submitterEmail: "",
            submitDate: Date(),
            approvalTimeoutInSeconds: 1000,
            numberOfDispositionsRequired: 1,
            numberOfApprovalsReceived: 1,
            numberOfDeniesReceived: 1,
            requestType: requestType
        )
    }
    
    func getRecentBlockhash() -> StrikeApi.Blockhash {
        return StrikeApi.Blockhash(
            id: "1",
            result: StrikeApi.Blockhash.Result(
                value: StrikeApi.Blockhash.Result.BlockhashData(blockhash: "123455")
            )
        )
    }
}
