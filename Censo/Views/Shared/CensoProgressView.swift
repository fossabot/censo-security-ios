//
//  CensoProgressView.swift
//  Censo
//
//  Created by Ata Namvari on 2022-07-12.
//

import SwiftUI

struct CensoProgressView: View {
    var text: String

    var body: some View {
        VStack(spacing: 30) {
            Text(text)
                .font(.callout)

            ProgressView()
        }
        .preferredColorScheme(.light)
        .foregroundColor(.Censo.primaryForeground)
        .padding(30)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color(white: 0.2), lineWidth: 1)
        )
    }
}
