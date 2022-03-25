//
//  FactsSection.swift
//  Strike
//
//  Created by Ata Namvari on 2021-05-04.
//

import Foundation
import SwiftUI

struct FactsSection: View {
    var title: String
    @FactBuilder var content: () -> [Fact]

    var body: some View {
        VStack(spacing: 0) {
            Header(title: title)
            FactList(facts: content)
        }
    }
}

struct Header: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.footnote)
            .frame(maxWidth: .infinity, minHeight: 22)
            .background(Color.Strike.thirdBackground /**/)
    }
}
