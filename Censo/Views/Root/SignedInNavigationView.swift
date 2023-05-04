//
//  SignedInNavigationView.swift
//  Censo
//
//  Created by Ata Namvari on 2021-05-19.
//

import Foundation
import SwiftUI

struct SignedInNavigationView<Content>: View where Content : View {
    @Environment(\.censoApi) var censoApi

    @State private var showingAlert = false
    @State private var activeSheet: Sheet?

    enum Sheet {
        case profile
    }

    @EnvironmentObject private var viewRouter: ViewRouter

    @RemoteResult private var user: CensoApi.User?

    var onSignOut: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        NavStackWorkaround {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.Censo.primaryBackground.ignoresSafeArea())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { activeSheet = .profile }, label: {
                            Image(systemName: "person")
                                .foregroundColor(.Censo.primaryForeground)
                        })
                    }
                }
                .sheet(item: $activeSheet) { sheet in
                    switch sheet {
                    case .profile:
                        Profile(user: user, onSignOut: onSignOut)
                    }
                }
                .onReceive(viewRouter.$showSupport) { showSupport in
                    guard user != nil, activeSheet == nil, showSupport else { return }
                    
                    activeSheet = .profile
                }
        }
        .onFirstTimeAppear {
            reload()
        }
    }

    func reload() {
        _user.reload(using: censoApi.provider.loader(for: .verifyUser(devicePublicKey: nil)))
    }
}

extension SignedInNavigationView.Sheet: Identifiable {
    var id: Int {
        switch self {
        case .profile:
            return 0
        }
    }
}
