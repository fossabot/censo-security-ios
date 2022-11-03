//
//  PublicKeys.swift
//  Strike
//
//  Created by Ata Namvari on 2022-10-31.
//

import Foundation
import CryptoKit

struct PublicKeys: Codable, Equatable {
    var solana: String
    var bitcoin: String
    var ethereum: String
}
