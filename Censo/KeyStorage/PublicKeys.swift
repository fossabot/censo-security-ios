//
//  PublicKeys.swift
//  Censo
//
//  Created by Ata Namvari on 2022-10-31.
//

import Foundation
import CryptoKit

struct PublicKeys: Codable, Equatable {
    var bitcoin: String
    var ethereum: String
    var censo: String
}
