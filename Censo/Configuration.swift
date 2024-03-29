//
//  Configuration.swift
//  Censo
//
//  Created by Donald Ness on 1/26/21.
//

import Foundation

struct Configuration {
    static let termsOfServiceURL: URL = URL(string: "https://censocustody.com/terms-of-service.html")!
    static let privacyPolicyURL: URL = URL(string: "https://censocustody.com/privacy-policy.html")!
    static let apiBaseURL: URL = URLValue(for: "API_BASE_URL")
    static let raygunApiKey: String = stringValue(for: "RAYGUN_API_KEY")
    static let raygunEnabled: Bool = stringValue(for: "RAYGUN_ENABLED").lowercased() == "yes"
    static let censoAuthBaseURL: URL = URLValue(for: "CENSO_AUTH_BASE_URL")
    static let minVersionURL: URL = URLValue(for: "MIN_VERSION_URL")
}

extension Configuration {
    static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary?["Configuration"] as? [String: Any] else {
            fatalError("`Info.plist` must contain a dictionary under `Configuration`")
        }

        return dict
    }()

    static func URLValue(for key: String) -> URL {
        guard let urlString = infoDictionary[key] as? String else {
            fatalError("`Info.plist` must contain key `\(key)`")
        }

        guard let url = URL(string: urlString) else {
            fatalError("`\(key)` is an invalid URL in `Info.plist`")
        }

        return url
    }

    static func stringValue(for key: String) -> String {
        guard let string = infoDictionary[key] as? String else {
            fatalError("`Info.plist` must contain key `\(key)`")
        }

        return string
    }

    static func dictionaryValue(for key: String) -> [String: String] {
        guard let dict = infoDictionary[key] as? [String: String] else {
            fatalError("`Info.plist` must contain a dictionary for key `\(key)`")
        }

        return dict
    }
}
