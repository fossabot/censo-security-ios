//
//  HelpView.swift
//  Censo
//
//  Created by Donald Ness on 3/27/21.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Need help?")
                .font(.caption)
                .bold()
                .textCase(.uppercase)
            HelpButton()
        }
    }
}
