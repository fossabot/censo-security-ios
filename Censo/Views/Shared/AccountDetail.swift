//
//  AccountDetail.swift
//  Censo
//
//  Created by Donald Ness on 2/18/21.
//

import SwiftUI

struct AccountDetail: View {
    var name: String
    var subname: String?
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(name)
                .font(Font.subheadline.bold())
                .foregroundColor(Color.white)

            if let subname = subname, subname != name {
                Text(subname)
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.5))
            }
        }
        .multilineTextAlignment(.center)
    }
}

#if DEBUG
struct TransactionAccountView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AccountDetail(name: "GK8", subname: "Example, Inc.")
            AccountDetail(name: "Coinbase")
        }
        .previewLayout(.fixed(width: 180, height: 60))
    }
}
#endif
