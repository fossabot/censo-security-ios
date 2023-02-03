//
//  PasswordManager.swift
//  Censo
//
//  Created by Ata Namvari on 2022-07-12.
//

import SwiftUI

struct PasswordManager: View {
    @Environment(\.presentationMode) var presentationMode

    var user: CensoApi.User
    var deviceKey: DeviceKey
    var phrase: [String]
    var onSuccess: () -> Void

    @State private var copied = false
    @State private var saved = false

    private let appForegroundedPublisher = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)

    var body: some View {
        VStack {
            BackButtonBar(caption: "Start over", presentationMode: presentationMode)

            Spacer()

            Text("Copy your secret recovery phrase to your clipboard")
                .font(.system(size: 26).bold())
                .multilineTextAlignment(.center)
                .padding()

            Button {
                UIPasteboard.general.string = phrase.joined(separator: " ")
                copied = true
            } label: {
                HStack {
                    Image(systemName: "square.on.square")
                        .frame(width: 20)
                        .padding([.leading], 10)
                    Spacer()
                    Text("Copy Recovery Phrase")
                    Spacer()
                    Spacer()
                        .frame(width: 30)
                }
                .frame(maxWidth: .infinity)
            }
            .padding([.leading, .trailing], 30)
            .padding([.top, .bottom])

            VStack {
                Image(systemName: "checkmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(height: 100)
                    .font(.title2.bold())

                Text("Copied to your clipboard!")
                    .padding([.leading, .trailing], 50)
                    .padding([.top, .bottom], 10)

                Text("Paste the recovery phrase in your Password Manager and come back here when it’s saved") // cut off
                    .padding([.leading, .trailing], 50)
                    .padding([.top, .bottom], 10)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.center)
            .opacity(copied ? 1 : 0)

            Spacer()

            NavigationLink {
                PasswordManagerConfirm(user: user, deviceKey: deviceKey, phrase: phrase, onSuccess: onSuccess)
            } label: {
                Text("I saved the phrase →")
                    .frame(maxWidth: .infinity)
            }
            .padding(30)
            .opacity(saved ? 1 : 0)

            Spacer()
                .frame(height: 20)
        }
        .buttonStyle(FilledButtonStyle())
        .navigationBarHidden(true)
        .background(CensoBackground())
        .onReceive(appForegroundedPublisher) { _ in
            saved = copied
        }
    }
}

#if DEBUG
struct PasswordManager_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PasswordManager(user: .sample, deviceKey: .sample, phrase: [], onSuccess: {})
        }
    }
}
#endif
