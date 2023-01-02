//
//  Profile.swift
//  Censo
//
//  Created by Ata Namvari on 2021-07-28.
//

import Foundation
import SwiftUI

struct Profile: View {
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject private var viewRouter: ViewRouter

    @State private var showingSignOutAlert = false

    var user: CensoApi.User?
    var onSignOut: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                List {
                    if let user = user {
                        Section {
                            ProfileItem(title: "Email") {
                                Text(user.loginName)
                            }
                            
                            ProfileItem(title: "Name") {
                                Text(user.fullName)
                            }
                        }
                    }

                    Section(
                        footer: VStack(alignment: .center, spacing: 20) {
                            Text("SECURITY NOTICE:")
                                .font(.subheadline.bold())

                            Text("To help protect your account's security Censo will never request any confidential information in regards to your account (such as password or secret recovery phrase).")

                            Spacer()

                            Button("Get Help", action: contactSupport)
                                .buttonStyle(PlainButtonStyle())
                                .foregroundColor(Color.Censo.blue)
                                .font(.headline.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .padding([.top, .bottom])
                        .multilineTextAlignment(.center)
                    ) {}
                }

                Spacer()

                #if DEBUG
                Text("App Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""))")
                    .font(.caption)
                #else
                Text("App Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                    .font(.caption)
                #endif

                Button("Sign Out") {
                    showingSignOutAlert = true
                }
                .buttonStyle(DestructiveButtonStyle())
                .padding()
            }
            .listRowBackground(Color.Censo.secondaryBackground)
            .font(.body)
            .background(Color.Censo.primaryBackground.ignoresSafeArea())
            .listStyle(GroupedListStyle())
            .navigationTitle(Text("User"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done", action: {
                presentationMode.wrappedValue.dismiss()
            }).foregroundColor(.white))
            .alert(isPresented: $showingSignOutAlert) {
                Alert(title: Text("Are you sure you want to sign out?"),
                      primaryButton: .default(Text("Yes")) {
                        presentationMode.wrappedValue.dismiss()
                        onSignOut()
                      },
                      secondaryButton: .cancel(Text("Cancel")))
            }
        }
        .onAppear {
            viewRouter.showSupport = false
        }
    }

    private func contactSupport() {
        if let helpUrl = URL(string: "https://help.censocustody.com"), UIApplication.shared.canOpenURL(helpUrl) {
            UIApplication.shared.open(helpUrl)
        }
    }
}

struct ProfileItem<Content>: View where Content : View {
    var title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack {
            Text(title)

            Spacer()

            content()
                .foregroundColor(Color.white.opacity(0.5))
        }
    }
}

#if DEBUG
struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile(user: .sample, onSignOut: {})
            .environmentObject(ViewRouter())
    }
}
#endif

extension CensoApi.User {
    static var sample: Self {
        CensoApi.User(
            id: "test",
            fullName: "John Malkovich",
            loginName: "john@hollywood.com",
            hasApprovalPermission: true,
            organization: CensoApi.Organization(
                id: "testOrg",
                name: "Hollywood Securities"
            ),
            useStaticKey: false,
            publicKeys: [],
            deviceKey: nil
        )
    }
}