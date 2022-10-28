//
//  WrapConversionDetail.swift
//  Strike
//
//  Created by Ata Namvari on 2022-06-08.
//

import Foundation
import SwiftUI

struct WrapConversionDetail: View {
    var request: ApprovalRequest
    var conversion: WrapConversionRequest

    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            FactList {
                Fact("Wallet", conversion.account.name)
                Fact("Swap for", conversion.destinationSymbolInfo.symbol)
            }
        }
    }
}

#if DEBUG
struct WrapConversionDetail_Previews: PreviewProvider {
    static var previews: some View {
        WrapConversionDetail(request: .sample, conversion: .sample)
            .background(Color.Strike.secondaryBackground.ignoresSafeArea())

        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        NavigationView {
            ApprovalRequestDetails(user: .sample, request: .sample, timerPublisher: timerPublisher) {
                WrapConversionDetail(request: .sample, conversion: .sample)
            }
        }
    }
}
#endif


