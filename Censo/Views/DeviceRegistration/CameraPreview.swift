//
//  CameraPreview.swift
//  Censo
//
//  Created by Ata Namvari on 2021-12-01.
//

import Foundation
import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    class PreviewView: UIView {
        init() {
            super.init(frame: .zero)

            NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }

        @objc func orientationChanged() {
            switch UIDevice.current.orientation {
            case .landscapeLeft:
                videoPreviewLayer.connection?.videoOrientation = .landscapeRight
            case .landscapeRight:
                videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
            case .portraitUpsideDown:
                break
            default:
                videoPreviewLayer.connection?.videoOrientation = .portrait
            }
        }
    }

    let session: AVCaptureSession

    func makeUIView(context: Context) -> some UIView {
        let view = PreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.cornerRadius = 0
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.orientationChanged()
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        // noop
    }
}
