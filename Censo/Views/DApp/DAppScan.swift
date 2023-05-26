//
//  DAppScan.swift
//  Censo
//
//  Created by Ata Namvari on 2021-12-01.
//

import SwiftUI
import AVFoundation
import Moya

struct DAppScan: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.censoApi) var censoApi

    @StateObject private var controller = CaptureController()

    @State private var connectionState: ConnectionState = .idle

    enum ConnectionState {
        case idle
        case validating(code: String)
        case connecting(topic: String, wallet: CensoApi.AvailableDAppWallet)
        case finished(CensoApi.WalletConnectSession, wallet: CensoApi.AvailableDAppWallet)
        case failed(Error)
    }

    var deviceKey: DeviceKey

    var body: some View {
        NavigationView {
            Group {
                switch (connectionState, controller.state) {
                case (.finished(let walletConnectSession, let wallet), _):
                    WalletSession(walletConnectSession: walletConnectSession, wallet: wallet) {
                        connectionState = .idle
                    }
                case (.failed(let error), _):
                    VStack {
                        Text("Failed")
                        Text(error.localizedDescription)

                        Button {
                            connectionState = .idle
                        } label: {
                            Text("Try Again")
                        }
                    }
                case (.connecting(let topic, let wallet), _):
                    ConnectingWallet(connectionState: $connectionState, topic: topic, wallet: wallet, deviceKey: deviceKey)
                case (_, .starting):
                    ProgressView {
                        Text("Starting capture device")
                    }
                case (_, .notAvailable(let error as NSError)) where error.domain == AVFoundationErrorDomain && error.code == -11852:
                    CameraAccessRequired()
                case (_, .notAvailable(let error)):
                    Text("Unable to start scan: \(error.localizedDescription)")
                case (_, .stopped):
                    ProgressView {
                        Text("Starting capture device")
                    }
                    .onAppear {
                        controller.restartCapture()
                    }
                case (_, .running(let session)):
                    ZStack {
                        CameraPreview(session: session)

                        VStack {
                            ZStack{
                                Rectangle()
                                    .foregroundColor(.black)
                                    .opacity(0.7)

                                switch connectionState {
                                case .validating(let code):
                                    NavigationLink(isActive: .constant(true)) {
                                        AvailableDAppWallets(code: code, deviceKey: deviceKey, connectionState: $connectionState)
                                    } label: {
                                        EmptyView()
                                    }
                                default:
                                    Text("Point the camera at the DApp's QR code")
                                }
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
                            }


                        }
                    }
                    .ignoresSafeArea(.all, edges: [.bottom])
                    .onReceive(controller.$code, perform: didReceiveNewCode)
                }
            }
            .navigationTitle(Text("Scan QR"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func didReceiveNewCode(_ code: String?) {
        guard case .idle = connectionState else {
            return
        }

        guard let code = code else {
            return
        }

        connectionState = .validating(code: code)
    }
}

extension DAppScan.ConnectionState {
    var isValidating: Bool {
        switch self {
        case .validating:
            return true
        default:
            return false
        }
    }
}
