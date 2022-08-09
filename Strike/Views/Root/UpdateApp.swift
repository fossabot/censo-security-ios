//
//  UpdateApp.swift
//  Strike
//
//  Created by Ata Namvari on 2022-08-09.
//

import SwiftUI

struct UpdateApp: View {
    var body: some View {
        VStack {
            Spacer()

            Text("This version of the Strike Security App is outdated. Please update to continue using it.")
                .multilineTextAlignment(.center)
                .padding()

            Button {
                gotoAppStore()
            } label: {
                Text("Update App")
            }
            .buttonStyle(FilledButtonStyle())

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(StrikeBackground().ignoresSafeArea())
    }

    private func gotoAppStore() {
        if let url = URL(string: "https://apps.apple.com/us/app/strike-security-app/id1566407098") {
            UIApplication.shared.open(url)
        }
    }
}

#if DEBUG
struct UpdateApp_Previews: PreviewProvider {
    static var previews: some View {
        UpdateApp()
    }
}
#endif
