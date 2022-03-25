//
//  LockedOutAccountView.swift
//  Strike
//
//  Created by Donald Ness on 3/25/21.
//

import SwiftUI
import OktaAuthNative

struct LockedOutAccountView: View {
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Your account has been locked out.")
            Text("Contact support to unlock your account.")

            Spacer()
            
            HelpButton()
        }
        .padding()
        .background(
            Color.Strike.secondaryBackground
                .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Locked Out")
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
struct LockedOutAccountView_Previews: PreviewProvider {
    static var previews: some View {
        LockedOutAccountView()
    }
}
#endif
