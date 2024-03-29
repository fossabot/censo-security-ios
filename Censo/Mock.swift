//
//  Mock.swift
//  Censo
//
//  Created by Donald Ness on 1/28/21.
//

import Foundation



struct Mock {
    
    struct censoApi {
        struct sampleData {
            static func verifyUser() -> Data {
                return encodeJsonData(json: [
                    "id": UUID().uuidString,
                    "fullName": "John Q. Public",
                    "loginName": "john@example.com",
                    "organization": [
                        "id": UUID().uuidString,
                        "name": "Example, Inc."
                    ]
                ])
            }
        }
    }
    
    // MARK: Helpers
    
    static let jsonDateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
      formatter.calendar = Calendar(identifier: .iso8601)
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      return formatter
    }()
    
    static func decodeJsonType<T: Decodable>(data: Data) -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(jsonDateFormatter)
        return try! decoder.decode(T.self, from: data)
    }
    
    static func decodeJsonType<T: Decodable>(json: Any) -> T {
        return decodeJsonType(data: encodeJsonData(json: json))
    }
    
    static func encodeJsonType<T: Encodable>(value: T) -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(jsonDateFormatter)
        return try! encoder.encode(value)
    }
    
    static func encodeJsonData(json: Any) -> Data {
        return try! JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    static func encodeJsonData(text: String) -> Data {
        return text.data(using: .utf8)!
    }
    
    static func encodeJsonString(json: Any) -> String {
        return String(data: encodeJsonData(json: json), encoding: .utf8)!
    }
}
