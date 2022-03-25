//
//  OktaUnsupportedStatusView.swift
//  Strike
//
//  Created by Donald Ness on 3/26/21.
//

import SwiftUI
import OktaAuthNative

struct UnsupportedAuthStatusView: View {
    @Environment(\.presentationMode) var presentation
    
    var status: OktaAuthStatus

    var body: some View {
        VStack() {
            Spacer()
            
            Text("Your account could not be authenticated.")
            Text("Contact support to resolve this issue.")

            Spacer()
            
            HelpButton()
        }
        .multilineTextAlignment(.center)
        .padding()
        .background(
            Color.Strike.secondaryBackground
                .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: close) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func close() {
        presentation.wrappedValue.dismiss()
    }
}

#if DEBUG
struct UnsupportedAuthStatusView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UnsupportedAuthStatusView(
                status: OktaAuthStatus(oktaDomain: Configuration.oktaDomain)
            )
        }
    }
}
#endif
