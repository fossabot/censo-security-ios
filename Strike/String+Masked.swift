//
//  String+Masked.swift
//  Strike
//
//  Created by Donald Ness on 2/18/21.
//

import Foundation

extension String {
    func masked(
        with maskCharacter: Character = "•",
        suffixLength: Int = 8,
        maskLength: Int = 12
    ) -> String {
        guard count > suffixLength else { return String(self) }
        return "\(String(repeating: maskCharacter, count: maskLength))\(suffix(suffixLength))"
    }
}
