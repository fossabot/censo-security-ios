//
//  CameraAccessRequired.swift
//  Censo
//
//  Created by Ata Namvari on 2021-12-01.
//

import SwiftUI

struct CameraAccessRequired: View {
    var body: some View {
        VStack {
            Spacer()

            Text("Camera Access Required")
                .font(.title2)
                .padding()

            Spacer()

            Text("The Censo Mobile App requires Camera Access to scan for QR codes.")
                .multilineTextAlignment(.leading)
                .padding()

            Button {
                goToAppSettings()
            } label: {
                Text("Enable in Settings")
                    .frame(maxWidth: .infinity)
            }
            .padding(30)
            .buttonStyle(FilledButtonStyle())

            Spacer()
        }
    }

    func goToAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
