//
//  CaptureController.swift
//  Censo
//
//  Created by Ata Namvari on 2021-12-01.
//

import Foundation
import AVFoundation

class CaptureController: NSObject, ObservableObject {
    @Published fileprivate(set) var state: CaptureState = .stopped
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

    func restartCapture() {
        guard let device = captureDevice else {
            state = .notAvailable(CaptureDeviceError.noCaptureDevice)
            return
        }

        videoQueue.async { [weak self] in
            do {
                let session = AVCaptureSession()
                let videoInput = try AVCaptureDeviceInput(device: device)
                let metadataOutput = AVCaptureMetadataOutput()
                let videoOutput = AVCaptureVideoDataOutput()

                guard session.canAddInput(videoInput),
                      session.canAddOutput(metadataOutput),
                      session.canAddOutput(videoOutput) else {
                    DispatchQueue.main.async {
                        self?.state = .notAvailable(CaptureDeviceError.deviceUnableToCaptureCode)
                    }
                    return
                }

                session.addInput(videoInput)
                session.addOutput(metadataOutput)
                session.addOutput(videoOutput)

                metadataOutput.metadataObjectTypes = [.qr]
                metadataOutput.setMetadataObjectsDelegate(self, queue: self?.videoQueue)

                session.startRunning()

                DispatchQueue.main.async {
                    self?.state = .running(session)
                }
            } catch {
                DispatchQueue.main.async {
                    self?.state = .notAvailable(error)
                }
            }
        }
    }

    func stopCapture() {
        switch state {
        case .running(let session):
            videoQueue.async { [weak self] in
                session.stopRunning()

                DispatchQueue.main.async {
                    self?.state = .stopped
                }
            }
        default:
            break
        }
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
