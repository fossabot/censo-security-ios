//
//  ChangeDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2021-05-13.
//

import Foundation
import SwiftUI

struct ChangeDetails<Changes, New, Old>: View where Changes : View, New : View, Old: View {
    @ViewBuilder var changes: () -> Changes
    @ViewBuilder var new: () -> New
    @ViewBuilder var old: () -> Old

    enum ViewMode: Int {
        case changes
        case new
        case old
    }

    @State private var viewMode: ViewMode = .changes

    var body: some View {
        VStack {
            Picker("", selection: $viewMode) {
                Text("Changes").tag(ViewMode.changes)
                Text("New").tag(ViewMode.new)
                Text("Old").tag(ViewMode.old)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(EdgeInsets(top: 20, leading: 36, bottom: 20, trailing: 36))

            switch viewMode {
            case .changes:
                changes()
            case .new:
                new()
            case .old:
                old()
            }
        }
    }
}
