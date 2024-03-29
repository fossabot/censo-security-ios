//
//  LoginRow.swift
//  Censo
//
//  Created by Ata Namvari on 2022-04-19.
//

import SwiftUI

struct LoginRow: View {
    var requestType: ApprovalRequestType
    var login: LoginApproval

    var body: some View {
        VStack(spacing: 8) {
            Text(requestType.header)
                .font(.title2.bold())
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .padding(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20))

            Text(login.email)
                .font(.title3)
                .foregroundColor(Color.Censo.primaryForeground.opacity(0.7))
                .padding(EdgeInsets(top: 2, leading: 20, bottom: 20, trailing: 20))
        }
    }
}

#if DEBUG
struct LoginRow_Previews: PreviewProvider {
    static var previews: some View {
        LoginRow(requestType: .loginApproval(.sample), login: .sample)
            .preferredColorScheme(.light)
    }
}

extension LoginApproval {
    static var sample: Self {
        LoginApproval(jwtToken: "sampleToken", email: "brenda@example.org", name: "Sample User Name")
    }
}

#endif
