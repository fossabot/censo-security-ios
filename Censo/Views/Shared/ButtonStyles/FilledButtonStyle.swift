//
//  FilledButtonStyle.swift
//  Censo
//
//  Created by Donald Ness on 3/25/21.
//

import SwiftUI

struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        FilledButton(configuration: configuration)
    }

    struct FilledButton: View {
        let configuration: ButtonStyle.Configuration
        @Environment(\.isEnabled) private var isEnabled: Bool

        var body: some View {
            configuration.label
                .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                .frame(minHeight: 44)
                .font(Font.body.bold())
                .foregroundColor(isEnabled ? Color.white : Color.white.opacity(0.35))
                .background(Color.Censo.backgroundBlue)
                .cornerRadius(12)
                .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("borderBlue"), lineWidth: 1)
                    )
        }
    }
}
