//
//  AlbumListCoordinator.swift
//  Sample App 1
//
//  Created by Dominik Pethö on 15/07/2024.
//

import UIKit
import SwiftUI

final class AlbumListCoordinator: Coordinator {

    init(rootViewController: UIViewController? = nil, parentCoordinator: Coordinator? = nil) {
        super.init(rootViewController: UINavigationController(), parentCoordinator: parentCoordinator)
    }

    override func start() -> UIViewController? {
        super.start()
        let view = AlbumsListView(viewModel: .init(coordinator: self))
        let controller = UIHostingController(rootView: view)
        let navigationController = UINavigationController(rootViewController: controller)
        rootViewController = navigationController
        controller.title = "Photos from API - List"
        return navigationController
    }

    override func navigate(to step: Coordinator.Step) -> StepAction {
        switch step {
        case let .openDetail(album):
//            let controller = UIHostingController(rootView: AlbumDetailView(viewModel: .init(album: album), coordinator: self))
//            let controller = UIHostingController(rootView: AlbumDetailView(viewModel: .init(coordinator: self, album: album)))
            let controller = UIHostingController(rootView: AlbumDetailView(viewModel: .init(album: album), coordinator: self))
            controller.title = "ALbum \(album.id)"
            return .push(controller)

        case .pop:
            return .pop
        }
    }

}
