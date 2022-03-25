//
//  BiometryError.swift
//  Strike
//
//  Created by Ata Namvari on 2022-03-25.
//

import Foundation

enum BiometryError: Error {
    case required
}

extension BiometryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .required:
            return "Biometric verification required to approve/ignore requests. Please enable it in settings."
        }
    }
}
