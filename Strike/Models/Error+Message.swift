//
//  Error+Message.swift
//  Strike
//
//  Created by Ata Namvari on 2022-08-02.
//

import Foundation
import Moya
import Alamofire

extension Error {

    var message: String {
        switch self as Error {
        case MoyaError.underlying(AFError.sessionTaskFailed(let error as NSError), _) where error.code == -1001:
            return "Your request timed out. Please retry"
        case MoyaError.underlying(AFError.sessionTaskFailed(let error as NSError), _) where error.code == -1009:
            return "You don't seem to be connected to the internet. Please check your connection and retry"
        case MoyaError.statusCode(let response) where response.statusCode == 418:
            return "Strike is upgrading its service, we should be back online shortly. Please retry in a few minutes"
        case BiometryError.required:
            return "Please enable biometry in settings to continue"
        case Keychain.KeychainError.couldNotLoad:
            return "Unable to retrieve data from your keychain"
        default:
            return "Something went wrong"
        }
    }

    var showsHelpButton: Bool {
        switch self as Error {
        case MoyaError.underlying(AFError.sessionTaskFailed(let error as NSError), _) where error.code == -1001:
            return false
        case MoyaError.underlying(AFError.sessionTaskFailed(let error as NSError), _) where error.code == -1009:
            return false
        case MoyaError.statusCode(let response) where response.statusCode == 418:
            return false
        case BiometryError.required:
            return false
        case Keychain.KeychainError.couldNotLoad:
            return false
        default:
            return true
        }
    }
}
