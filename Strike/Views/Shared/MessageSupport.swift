//
//  MessageSupport.swift
//  Strike
//
//  Created by Ata Namvari on 2021-05-17.
//

import Foundation
import SwiftUI

struct MessageSupport: ViewModifier {
    @State private var message: Message? = nil

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
                .onPreferenceChange(MessagePreferenceKey.self) { value in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        message = value
                    }
                }

            if let message = message {
                message.content
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

extension View {
    func withMessageSupport() -> some View {
        modifier(MessageSupport())
    }
}

struct MessagePreferenceKey: PreferenceKey {
    static var defaultValue: Message? = nil

    static func reduce(value: inout Message?, nextValue: () -> Message?) {
        value = nextValue()
    }
}

struct Message: Equatable {
    var id = UUID()
    var content: AnyView

    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension View {
    func message<Content>(_ isShowing: Binding<Bool>, @ViewBuilder content: () -> Content) -> some View where Content : View {
        preference(key: MessagePreferenceKey.self,
                   value: isShowing.wrappedValue ? Message(content: AnyView(content())) : nil)
    }
}
