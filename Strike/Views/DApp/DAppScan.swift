//
//  DAppScan.swift
//  Strike
//
//  Created by Ata Namvari on 2021-12-01.
//

import SwiftUI
import AVFoundation
import Moya

struct DAppScan: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.strikeApi) var strikeApi

    @StateObject private var controller = CaptureController()

    @State private var alert: AlertType? = nil
    @State private var requestInProgress = false
    @State private var connectedWallt: StrikeApi.ConnectedWallet? = nil

    enum AlertType {
        case error(Error)
    }

    var body: some View {
        NavigationView {
            Group {
                switch (connectedWallt, controller.state) {
                case (.some(let connectedWallet), _):
                    WalletConnected(connectedWallet: connectedWallet)
                case (_, .starting):
                    ProgressView {
                        Text("Starting capture device")
                    }
                case (_, .notAvailable(let error as NSError)) where error.domain == AVFoundationErrorDomain && error.code == -11852:
                    CameraAccessRequired()
                case (_, .notAvailable(let error)):
                    Text("Unable to start scan: \(error.localizedDescription)")
                case (_, .stopped):
                    Text("Scan paused")
                case (_, .running(let session)):
                    ZStack {
                        CameraPreview(session: session)

                        VStack {
                            ZStack{
                                Rectangle()
                                    .foregroundColor(.black)
                                    .opacity(0.7)

                                if requestInProgress {
                                    ProgressView("Validating QR code")
                                        .foregroundColor(.white)
                                } else {
                                    Text("Point the camera at the DApp's QR code")
                                        .foregroundColor(.white)
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
                case .error(let connectionError as StrikeApi.WalletConnectionError):
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
        guard !requestInProgress, alert == nil else {
            return
        }

        guard let code = code else {
            return
        }

        requestInProgress = true

        strikeApi.provider.decodableRequest(.connectDApp(code: code), completionQueue: nil) { (result: Result<StrikeApi.ConnectedWallet, MoyaError>) in
            switch result {
            case .failure(MoyaError.statusCode(let response)):
                let decoder = JSONDecoder()
                let error = try? decoder.decode(StrikeApi.WalletConnectionError.self, from: response.data)
                alert = .error(error ?? MoyaError.statusCode(response))
            case .failure(let error):
                alert = .error(error)
            case .success(let connectedWallet):
                self.connectedWallt = connectedWallet
            }

            requestInProgress = false
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
