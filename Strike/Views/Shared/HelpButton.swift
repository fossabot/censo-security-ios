//
//  HelpButton.swift
//  Strike
//
//  Created by Donald Ness on 3/5/21.
//

import SwiftUI

struct HelpButton: View {
    @State private var isPresentingActionSheet: Bool = false
    
    var body: some View {
        Button(action: presentActionSheet) {
            Text("Contact Strike Protocols, Inc.")
                .frame(maxWidth: .infinity, minHeight: 55)
                .font(Font.subheadline.bold())
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white, lineWidth: 1)
                )
        }
        .actionSheet(isPresented: $isPresentingActionSheet, content: createActionSheet)
    }
    
    private func presentActionSheet() {
        isPresentingActionSheet = true
    }
    
    private func createActionSheet() -> ActionSheet {
        var buttons = [ActionSheet.Button]()
        
        let app = UIApplication.shared

        buttons.append(ActionSheet.Button.default(Text("Get Support")) {
            if let supportURL = URL(string: "https://support.strikeprotocols.com"), app.canOpenURL(supportURL) {
                app.open(supportURL)
            }
        })
        
        buttons.append(ActionSheet.Button.default(Text("Call +1 (856) 644-2217")) {
            if let telURL = URL(string: "tel:+1-856-644-2217"), app.canOpenURL(telURL) {
                app.open(telURL)
            }
        })
        
        buttons.append(ActionSheet.Button.cancel())
        
        return ActionSheet(title: Text("Contact Strike Protocols, Inc."), message: nil, buttons: buttons)
    }
}

struct HelpButton_Previews: PreviewProvider {
    static var previews: some View {
        HelpButton()
    }
}
