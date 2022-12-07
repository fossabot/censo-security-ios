//
//  PasswordResetRow.swift
//  Censo
//
//  Created by Brendan Flood on 8/10/22.
//
import SwiftUI

struct PasswordResetRow: View {
    var requestType: ApprovalRequestType
    var email: String

    var body: some View {
        VStack(spacing: 8) {
            Text(requestType.header)
                .font(.title2.bold())
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .foregroundColor(Color.white)
                .padding(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20))
            
            Text(email)
                .font(.title3)
                .foregroundColor(Color.white.opacity(0.8))
                .padding(EdgeInsets(top: 2, leading: 20, bottom: 20, trailing: 20))
        }
    }
}

#if DEBUG
struct PasswordResetRow_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetRow(requestType: .passwordReset(.sample), email: "a@b.com")
    }
}

extension PasswordReset {
    static var sample: Self {
        PasswordReset()
    }
}

#endif

