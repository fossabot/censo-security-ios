//
//  PhotoCapture.swift
//  Strike
//
//  Created by Ata Namvari on 2022-11-29.
//

import SwiftUI
import AVFoundation
import Moya

struct PhotoCapture: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.strikeApi) var strikeApi

    @StateObject private var controller = PhotoCaptureController()

    @State private var alert: AlertType? = nil

    enum AlertType {
        case error(Error)
    }

    var onPhoto: (CGImage) -> Void

    var body: some View {
        NavigationView {
            Group {
                switch controller.photo {
                case .none:
                    switch controller.state {
                    case .starting:
                        ProgressView {
                            Text("Starting capture device")
                        }
                    case .notAvailable(let error as NSError) where error.domain == AVFoundationErrorDomain && error.code == -11852:
                        CameraAccessRequired()
                    case .notAvailable(let error):
                        Text("Unable to start camera: \(error.localizedDescription)")
                    case .stopped:
                        Text("Camera paused")
                    case .running(let session):
                        ZStack {
                            CameraPreview(session: session)

                            VStack {
                                ZStack{
                                    Rectangle()
                                        .foregroundColor(.black)
                                        .opacity(0.7)

                                    Text("Let's take your photo")
                                        .foregroundColor(.white)
                                }

                                GeometryReader { geometry in
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 5)
                                        .foregroundColor(.white.opacity(0.5))
                                        .padding(geometry.size.width / 5)
                                }
                                .aspectRatio(1, contentMode: .fill)

                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.black)
                                        .opacity(0.7)

                                    Button {
                                        controller.capturePhoto()
                                    } label: {
                                        Text("Capture")
                                    }
                                }
                            }
                        }
                        .ignoresSafeArea(.all, edges: [.bottom])
                    }
                case .some(let photo):
                    VStack {
                        Image(cgImage: photo)

                        HStack {
                            Button {
                                controller.photo = nil
                            } label: {
                                Text("Retake")
                            }

                            Spacer()

                            Button {
                                onPhoto(photo)
                            } label: {
                                Text("Use")
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text("Capture Photo"))
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        presentationMode.wrappedValue.dismiss()
//                    } label: {
//                        Image(systemName: "xmark")
//                            .foregroundColor(.white)
//                    }
//                }
//            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

