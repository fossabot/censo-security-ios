//
//  RefreshScrollView.swift
//  Strike
//
//  Created by Ata Namvari on 2021-04-28.
//

import Foundation
import SwiftUI
import UIKit

struct RefreshContext {
    let onEndRefreshing: () -> Void

    func endRefreshing() {
        onEndRefreshing()
    }
}

struct RefreshScrollView<Content>: UIViewControllerRepresentable where Content : View {
    let content: Content
    let onRefresh: (RefreshContext) -> Void

    init(onRefresh: @escaping (RefreshContext) -> Void, @ViewBuilder content: () -> Content) {
        self.onRefresh = onRefresh
        self.content = content()
    }

    func makeUIViewController(context: Context) -> ScrollViewController {
        let controller = ScrollViewController()

        let contentView = context.coordinator.controller.view!
        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false

        context.coordinator.controller.willMove(toParent: controller)
        controller.addChild(context.coordinator.controller)

        controller.scrollView.addSubview(contentView)
        controller.scrollView.addConstraints([
            contentView.leadingAnchor.constraint(equalTo: controller.scrollView.contentLayoutGuide.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: controller.scrollView.contentLayoutGuide.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: controller.scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: controller.scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: controller.scrollView.frameLayoutGuide.widthAnchor)
        ])

        context.coordinator.controller.didMove(toParent: controller)

        return controller
    }

    func updateUIViewController(_ uiViewController: ScrollViewController, context: Context) {
        uiViewController.onRefresh = onRefresh
        uiViewController.view.isUserInteractionEnabled = context.environment.isEnabled
        context.coordinator.controller.rootView = AnyView(content.environment(\.self, context.environment))
    }

    static func dismantleUIViewController(_ uiViewController: ScrollViewController, coordinator: Coordinator) {
        guard uiViewController.parent != nil else {
            return
        }

        uiViewController.children.forEach { vc in
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
            vc.didMove(toParent: nil)
        }

        _ = uiViewController
            .navigationController?
            .viewControllers
            .filter { vc in
                uiViewController.isDescendant(of: vc)
            }
            .last
            .flatMap { vc in
                uiViewController.navigationController?.popToViewController(vc, animated: true)
            }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: RefreshScrollView<Content>
        var controller: UIHostingController<AnyView>

        init(_ parent: RefreshScrollView<Content>) {
            self.parent = parent
            self.controller = UIHostingController(rootView: AnyView(EmptyView()))
        }

        @objc func beginRefreshing(_ sender: UIRefreshControl) {
            parent.onRefresh(RefreshContext(onEndRefreshing: sender.endRefreshing))
        }
    }
}

class ScrollViewController: UIViewController {
    var scrollView: UIScrollView {
        self.view as! UIScrollView
    }

    var onRefresh: ((RefreshContext) -> Void)?

    override func loadView() {
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .automatic
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefresh(_:)), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        self.view = scrollView
    }

    override func viewDidLoad() {
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    @objc func didRefresh(_ sender: UIRefreshControl) {
        onRefresh?(RefreshContext {
            sender.endRefreshing()
        })
    }
}

extension UIViewController {
    func isDescendant(of controller: UIViewController) -> Bool {
        controller.children.reduce(controller.children.contains(self)) { result, vc in
            result || isDescendant(of: vc)
        }
    }
}
