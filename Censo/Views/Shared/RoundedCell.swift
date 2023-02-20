//
//  RoundedCell.swift
//  Censo
//
//  Created by Donald Ness on 3/5/21.
//

import SwiftUI

struct RoundedCell: ViewModifier {
    
    let background: Color
    
    func body(content: Content) -> some View {
        content
            .background(background)
            .cornerRadius(8)
    }
}

extension View {
    func roundedCell(background: Color = .Censo.lightGray) -> some View {
        modifier(RoundedCell(background: background))
    }
}
