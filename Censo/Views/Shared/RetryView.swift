//
//  RetryView.swift
//  Censo
//
//  Created by Ata Namvari on 2021-04-05.
//

import Foundation
import SwiftUI

struct RetryView: View {
    var error: Error
    var action: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text(error.message)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: action) {
                Text("Retry")
                    .frame(width: 100)
            }
            .buttonStyle(FilledButtonStyle())

            if error.showsHelpButton {
                Button(action: showHelp) {
                    Text("Get Help")
                }
                .foregroundColor(.Censo.red)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(CensoBackground().ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
    }

    private func showHelp() {
        if let helpUrl = URL(string: "https://help.censocustody.com"), UIApplication.shared.canOpenURL(helpUrl) {
            UIApplication.shared.open(helpUrl)
        }
    }
}

#if DEBUG
struct RetryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RetryView(error: BiometryError.required, action: { })
                .navigationTitle(Text("Approvals"))
        }
    }
}
#endif
