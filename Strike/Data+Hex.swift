//
//  Data+Hex.swift
//  Strike
//
//  Created by Ata Namvari on 2021-04-28.
//

import Foundation

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
