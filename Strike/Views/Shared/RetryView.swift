//
//  RetryView.swift
//  Strike
//
//  Created by Ata Namvari on 2021-04-05.
//

import Foundation
import SwiftUI

struct RetryView: View {
    var error: Error
    var action: () -> Void

    var body: some View {
        VStack {
            Text("Something went wrong")
                .multilineTextAlignment(.center)
                .padding()

            Button(action: action) {
                Text("Retry")
            }
        }
    }
}
