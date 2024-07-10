//
//  AlbumsGridCoordinator.swift
//  Sample App 1
//
//  Created by Dominik Pethö on 15/07/2024.
//

import Foundation

import UIKit
import SwiftUI

final class AlbumGridCoordinator: Coordinator {

    init(rootViewController: UIViewController? = nil, parentCoordinator: Coordinator? = nil) {
        super.init(rootViewController: rootViewController, parentCoordinator: parentCoordinator)
    }

    override func start() -> UIViewController? {
        super.start()
        
        let view = AlbumsGridView(viewModel: .init(coordinator: self))
        let controller = UIHostingController(rootView: view)
        let navigationController = UINavigationController(rootViewController: controller)
        controller.title = "Photos from API - Grid"
        rootViewController = navigationController
        return navigationController
    }

    override func navigate(to step: Coordinator.Step) -> StepAction {
        switch step {
        case let .openDetail(album):
//            let controller = UIHostingController(rootView: AlbumDetailView(viewModel: .init(album: album), coordinator: self))
//            let controller = UIHostingController(rootView: AlbumDetailView(viewModel: .init(coordinator: self, album: album)))
            let controller = UIHostingController(rootView: AlbumDetailView(viewModel: .init(album: album), coordinator: self))
            controller.title = "Album \(album.id)"
            return .push(controller, ignoreBackButtonTitle: true, animated: true)

        case .pop:
            return .pop
        }
    }

}
