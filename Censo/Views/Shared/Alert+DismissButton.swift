//
//  Alert.swift
//  Censo
//
//  Created by Donald Ness on 3/30/21.
//

import SwiftUI

extension Alert {
    static func withDismissButton(title: Text, message: Text?) -> Alert {
        return Alert(
            title: title,
            message: message,
            dismissButton: Alert.Button.cancel(Text("Dismiss"))
        )
    }
}
