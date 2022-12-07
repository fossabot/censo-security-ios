//
//  ApprovalDispositionRequest+Signable.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-11.
//

import Foundation
import Moya
import CryptoKit

struct ApprovalDispositionRequest {
    let disposition: ApprovalDisposition
    let request: ApprovalRequest
}

