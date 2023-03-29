//
//  PhotoCapture.swift
//  Censo
//
//  Created by Ata Namvari on 2023-02-02.
//

import SwiftUI

struct PhotoCapture<Submission>: View where Submission : View {
    typealias RetakeClosure = () -> Void

    @StateObject private var controller = PhotoCaptureController()

    var deviceKey: DeviceKey
    @ViewBuilder var submission: (UIImage, @escaping RetakeClosure) -> Submission

    var body: some View {
        switch (controller.photo, controller.state) {
        case (.some(let uiImage), _):
            submission(uiImage) {
                controller.photo = nil
            }
        case (.none, .notAvailable):
            CameraNotAvailable()
        case (.none, .running(let session, _)):
            VStack(spacing: 40) {
                Text("Lets take your photo")

                CameraPreview(session: session)
                    .aspectRatio(1, contentMode: .fit)

                Button {
                    controller.capturePhoto()
                } label: {
                    Text("Capture")
                }
                .buttonStyle(FilledButtonStyle())
            }
        case (.none, .starting):
            ProgressView()
        case (.none, .stopped):
            ProgressView()
                .onAppear {
                    controller.restartCapture()
                }
        }
    }
}
