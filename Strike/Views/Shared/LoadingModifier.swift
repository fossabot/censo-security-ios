//
//  LoadingModifier.swift
//  Strike
//
//  Created by Donald Ness on 3/27/21.
//

import Foundation
import SwiftUI

struct LoadingModifier: ViewModifier {
    var isLoading: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isLoading {
            ProgressView()
        } else {
            content
        }
    }
}

extension View {
    func loadingIndicator(when isLoading: Bool) -> some View {
        modifier(LoadingModifier(isLoading: isLoading))
    }
}
