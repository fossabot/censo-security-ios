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

    @State private var alert: AlertType? = nil
    @State private var connectionState: ConnectionState = .idle

    enum ConnectionState {
        case idle
        case validating
        case connecting(topic: String)
        case finished(CensoApi.WalletConnectSession)
        case failed(Error)
    }

    enum AlertType {
        case error(Error)
    }

    var body: some View {
        NavigationView {
            Group {
                switch (connectionState, controller.state) {
                case (.finished(let walletConnectSession), _):
                    WalletSession(walletConnectSession: walletConnectSession) {
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
                case (.connecting(let topic), _):
                    ConnectingWallet(connectionState: $connectionState, topic: topic)
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
                                case .validating:
                                    ProgressView("Validating QR code")
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
            .alert(item: $alert) { alert in
                switch alert {
                case .error(let connectionError as CensoApi.WalletConnectionError):
                    return Alert(
                        title: Text("Error"),
                        message: Text(connectionError.errors.first?.message ?? "Could not connect wallet"),
                        dismissButton: .cancel(Text("Ok"))
                    )
                case .error:
                    return Alert(
                        title: Text("Error"),
                        message: Text("Something went wrong"),
                        dismissButton: .cancel(Text("Ok"))
                    )
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func didReceiveNewCode(_ code: String?) {
        guard case .idle = connectionState, alert == nil else {
            return
        }

        guard let code = code else {
            return
        }

        guard let topic = code.components(separatedBy: "@2").first?.dropFirst(3) else {
            return
        }

        connectionState = .validating

        censoApi.provider.request(.connectDApp(code: code)) { result in
            switch result {
            case .success(let response) where response.statusCode >= 400:
                let decoder = JSONDecoder()
                let error = try? decoder.decode(CensoApi.WalletConnectionError.self, from: response.data)
                alert = .error(error ?? MoyaError.statusCode(response))
                connectionState = .idle
            case .failure(let error):
                alert = .error(error)
                connectionState = .idle
            case .success:
                connectionState = .connecting(topic: String(topic))
            }
        }
    }
}

extension DAppScan.AlertType: Identifiable {
    var id: String {
        switch self {
        case .error(let error):
            return error.localizedDescription
        }
    }
}


