//
//  CameraNotAvailable.swift
//  Censo
//
//  Created by Ata Namvari on 2023-02-02.
//

import SwiftUI

struct CameraNotAvailable: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Unable to Access Camera")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Grant Censo access to your camera in order to take your photo.")
                .multilineTextAlignment(.center)
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Text("In your Settings App, go to Privacy > Camera and verify the switch next to COMMMAND Center is on to continue.")
                .multilineTextAlignment(.center)
                .font(.footnote)

            Button(action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }) {
                Text("Open Settings App")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 32)
    }
}
