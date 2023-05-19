//
//  NavStackWorkaround.swift
//  Censo
//
//  Created by Ata Namvari on 2023-03-23.
//

import Foundation
import SwiftUI

// Theres an issue with iOS 16 and NavigationView where it sometimes crashes due to a memory corruption
//
// -[_TtGC7SwiftUI41StyleContextSplitViewNavigationControllerVS_19SidebarStyleContext_ removeChildViewController:]: message sent to deallocated instance
//
// For this reason and to support backwards compatibility with iOS 15 the following replacement for NavigationStack/NavigationView
// should be used where it uses the latest API available depending on the os version
//
// Furthermore, on iOS 16.4 the NavigationStack contracted a bug where nested State variable changes do not trigger a rerender of the UI
// until any touch interaction is performed on the device
//

struct NavStackWorkaround<T: View>: View {
    @ViewBuilder let content: () -> T

    var body: some View {
        if #available(iOS 16.4, *) {
            NavigationView(content: content)
                .navigationViewStyle(.stack)
        } else if #available(iOS 16, *) {
            NavigationStack(root: content)
        } else {
            NavigationView(content: content)
                .navigationViewStyle(.stack)
        }
    }
}
