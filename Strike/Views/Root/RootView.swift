//
//  RootView.swift
//  Strike
//
//  Created by Ata Namvari on 2021-03-09.
//

import Foundation
import SwiftUI
import Moya

struct RootView: View {
    #if STUBBED
    var body: some View {
        MainView(onSignOut: {})
            .environment(\.strikeApi, StrikeApi(authProvider: nil, stubClosure: MoyaProvider.delayedStub(0.5)))
    }
    #else

    @ObservedObject var authProvider: OktaAuthProvider

    var body: some View {
        if authProvider.isAuthenticated {
            MainView(onSignOut: signOut)
                .environment(\.strikeApi, StrikeApi(authProvider: authProvider))
        } else {
            SignInView(authProvider: authProvider)
        }
    }



    private func signOut() {
        NotificationCenter.default.post(name: .userWillSignOut, object: nil)
        authProvider.invalidate()
    }
    #endif
}


#if DEBUG
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        #if STUBBED
        RootView()
        #else
        RootView(authProvider: .init())
        #endif
    }
}
#endif
