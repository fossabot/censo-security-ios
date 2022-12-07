//
//  PhotoCaptureController.swift
//  Strike
//
//  Created by Ata Namvari on 2022-11-29.
//

import Foundation
import AVFoundation

class PhotoCaptureController: NSObject, ObservableObject {
    @Published fileprivate(set) var state: CaptureState = .stopped
    @Published var photo: UIImage?

    private let captureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: .front)
    private let videoQueue = DispatchQueue(label: "video-capture-queue")
    private var _capturePhoto: (() -> Void)?

    enum CaptureState {
        case starting
        case notAvailable(Error)
        case running(AVCaptureSession, AVCapturePhotoOutput)
        case stopped
    }

    enum CaptureDeviceError: Error {
        case noCaptureDevice
        case deviceUnableToCapturePhoto
    }

    deinit {
        stopCapture()
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
                let photoOutput = AVCapturePhotoOutput()
                photoOutput.isHighResolutionCaptureEnabled = true
                let videoOutput = AVCaptureVideoDataOutput()

                guard session.canAddInput(videoInput),
                      session.canAddOutput(photoOutput),
                      session.canAddOutput(videoOutput) else {
                    DispatchQueue.main.async {
                        self?.state = .notAvailable(CaptureDeviceError.deviceUnableToCapturePhoto)
                    }
                    return
                }

                session.addInput(videoInput)
                session.addOutput(photoOutput)
                session.addOutput(videoOutput)

                session.startRunning()

                DispatchQueue.main.async {
                    self?.state = .running(session, photoOutput)
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
        case .running(let session, _):
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

    func capturePhoto() {
        switch state {
        case .running(_, let photoOutput):
            videoQueue.async {
                let settings = AVCapturePhotoSettings()
                photoOutput.capturePhoto(with: settings, delegate: self)
            }
        default:
            break
        }
    }
}


extension PhotoCaptureController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard
            error == nil,
            let dataImage = photo.fileDataRepresentation()
            else {
                fatalError("Unable to capture the photo due to an error")
        }

        let dataProvider = CGDataProvider(data: dataImage as CFData)
        let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)

        let temp = CIImage(cgImage: cgImageRef)
        var ciImage = temp;

        switch UIDevice.current.orientation {
        case .portrait:
            ciImage = temp.oriented(forExifOrientation: 6)
        case .landscapeRight:
            ciImage = temp.oriented(forExifOrientation: 3)
        case .landscapeLeft:
            ciImage = temp.oriented(forExifOrientation: 1)
        default:
            break
        }

        let image = UIImage(ciImage: ciImage)

        DispatchQueue.main.async {
            self.photo = image.squared()!
        }
    }
}

extension UIImage {
    var isPortrait:  Bool    { size.height > size.width }
    var isLandscape: Bool    { size.width > size.height }
    var breadth:     CGFloat { min(size.width, size.height) }
    var breadthSize: CGSize  { .init(width: breadth, height: breadth) }
    func squared(isOpaque: Bool = false) -> UIImage? {
        guard let ciImage = ciImage?
            .cropped(to: .init(origin: .init(x: isLandscape ? ((size.width-size.height)/2).rounded(.down) : 0,
                                              y: isPortrait  ? ((size.height-size.width)/2).rounded(.down) : 0),
                                size: breadthSize)) else { return nil }
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: breadthSize, format: format).image { _ in
            UIImage(ciImage: ciImage, scale: 1, orientation: imageOrientation)
            .draw(in: .init(origin: .zero, size: breadthSize))
        }
    }
}
