//
//  EmptyApprovalRequestsList.swift
//  Censo
//
//  Created by Ata Namvari on 2021-09-01.
//

import Foundation
import SwiftUI

struct EmptyApprovalRequestsList: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Spacer()

            Text("Nothing to approve")
                .font(.title.bold())

            Spacer()

            Text("Pull down to refresh approvals")
                .font(.body.bold())

            Image(systemName: "arrow.down")
        }
        .foregroundColor(Color.white.opacity(0.5))
    }
}
