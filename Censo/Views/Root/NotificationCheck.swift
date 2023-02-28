//
//  NotificationCheck.swift
//  Censo
//
//  Created by Ata Namvari on 2023-02-15.
//

import SwiftUI

struct NotificationCheck<Content>: View where Content : View {
    @State private var notificationStatus: UNAuthorizationStatus = .denied

    @AppStorage private var userPromptedForPush: Bool

    var content: () -> Content

    init(email: String, @ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
        self._userPromptedForPush = AppStorage(wrappedValue: false, "userPromptedForPush-\(email)")
    }

    var body: some View {
        Group {
            if !userPromptedForPush {
                VStack {
                    Spacer()

                    Text("Censo would like to send you push notifications")
                        .padding()
                        .multilineTextAlignment(.center)

                    Spacer()

                    Button {
                        registerForRemoteNotifications()
                    } label: {
                        Text("Enable Notifications")
                    }
                    .buttonStyle(FilledButtonStyle())

                    Button {
                        self.userPromptedForPush = true
                    } label: {
                        Text("Skip")
                            .bold()
                            .foregroundColor(.Censo.red)
                    }
                    .padding()

                    Spacer()
                }
            } else {
                content()
                    .onFirstTimeAppear {
                        if notificationStatus == .authorized {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
            }
        }
        .onFirstTimeAppear {
            fetchNotificationStatus()
        }
    }

    private func fetchNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            self.notificationStatus = settings.authorizationStatus
        }
    }

    private func registerForRemoteNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (_, _) in
            DispatchQueue.main.async {
                fetchNotificationStatus()
                userPromptedForPush = true
            }
        }
    }
}

#if DEBUG
struct NotificationCheck_Previews: PreviewProvider {
    static var previews: some View {
        NotificationCheck(email: "", {})
    }
}
#endif
