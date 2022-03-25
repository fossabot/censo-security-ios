//
//  OktaError+LocalizedError.swift
//  Strike
//
//  Created by Donald Ness on 4/5/21.
//

import Foundation
import OktaAuthNative

extension OktaError: LocalizedError {
    public var errorDescription: String? {
        return localizedDescription
    }
}
