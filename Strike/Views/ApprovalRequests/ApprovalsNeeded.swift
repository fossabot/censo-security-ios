//
//  ApprovalsNeeded.swift
//  Strike
//
//  Created by Ata Namvari on 2021-05-19.
//

import Foundation
import SwiftUI


struct ApprovalsNeeded: View {
    var request: ApprovalRequest

    var body: some View {
        let numApprovalsNeeded = request.numberOfDispositionsRequired - request.numberOfApprovalsReceived

        HStack(spacing: 0) {
            if numApprovalsNeeded > 0 {
                Text("\(numApprovalsNeeded)")
                    .fontWeight(.bold)
                Text(" more approval\(numApprovalsNeeded == 1 ? "" : "s") needed")
            } else {
                Text("No more approvals needed")
            }
        }
        .font(.caption)
        .foregroundColor(Color.white.opacity(0.5))
        .padding(.top)
    }
}
