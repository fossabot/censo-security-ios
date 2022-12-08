//
//  DestructiveButtonStyle.swift
//  Censo
//
//  Created by Ata Namvari on 2021-04-20.
//

import SwiftUI

struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration
            .label
            .frame(maxWidth: .infinity, minHeight: 45)
            .font(Font.subheadline.bold())
            .foregroundColor(Color.Censo.red)
            .background(Color.Censo.red.opacity(0.2))
            .cornerRadius(8)
            .progressViewStyle(CircularProgressViewStyle(tint: Color.Censo.red))
    }
}
