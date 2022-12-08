//
//  CaptureController.swift
//  Censo
//
//  Created by Ata Namvari on 2021-12-01.
//

import Foundation
import AVFoundation

class CaptureController: NSObject, ObservableObject {
    @Published fileprivate(set) var state: CaptureState = .starting
    @Published fileprivate(set) var code: String?

    private let session = AVCaptureSession()
    private let captureDevice = AVCaptureDevice.default(for: .video)
    private let videoQueue = DispatchQueue(label: "video-capture-queue")

    enum CaptureState {
        case starting
        case notAvailable(Error)
        case running(AVCaptureSession)
        case stopped
    }

    enum CaptureDeviceError: Error {
        case noCaptureDevice
        case deviceUnableToCaptureCode
    }

    override init() {
        super.init()

        guard let device = captureDevice else {
            state = .notAvailable(CaptureDeviceError.noCaptureDevice)
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: device)
            let metadataOutput = AVCaptureMetadataOutput()
            let videoOutput = AVCaptureVideoDataOutput()

            guard session.canAddInput(videoInput),
                  session.canAddOutput(metadataOutput),
                  session.canAddOutput(videoOutput) else {
                state = .notAvailable(CaptureDeviceError.deviceUnableToCaptureCode)
                return
            }

            session.addInput(videoInput)
            session.addOutput(metadataOutput)
            session.addOutput(videoOutput)

            metadataOutput.metadataObjectTypes = [.qr]
            metadataOutput.setMetadataObjectsDelegate(self, queue: videoQueue)

            session.startRunning()
            state = .running(session)
        } catch {
            state = .notAvailable(error)
        }
    }

    deinit {
        session.stopRunning()
    }

    func restartCapture() {
        session.startRunning()
        state = .running(session)
    }

    func stopCapture() {
        session.stopRunning()
        state = .stopped
    }
}

extension CaptureController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        let code = metadataObjects
            .compactMap { $0 as? AVMetadataMachineReadableCodeObject }
            .compactMap(\.stringValue)
            .first

        DispatchQueue.main.async {
            self.code = code
        }
    }
}
