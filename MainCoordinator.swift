//
//  MainCoordinator.swift
//  Sample App 1
//
//  Created by Dominik Pethö on 15/07/2024.
//

import Foundation
import UIKit
import SwiftUI

enum AppStep {
    case openDetail(Album)
    case pop
}

final class MainCoordinator: Coordinator {

    init(rootViewController: UIViewController? = nil) {
        super.init(rootViewController: rootViewController)
    }

    override func start() -> UIViewController? {
        super.start()
        let tabbarController = TabBarController()
        rootViewController = tabbarController
        if let listController = AlbumListCoordinator(parentCoordinator: self).start() {
            listController.tabBarItem = UITabBarItem(
                title: "List",
                image: UIImage(systemName: "rectangle.grid.1x2"),
                selectedImage: UIImage(systemName: "rectangle.grid.1x2.fill")
            )
            tabbarController.addChild(listController)
        }
        if let listController = AlbumGridCoordinator(parentCoordinator: self).start() {
            listController.tabBarItem = UITabBarItem(
                title: "Grid",
                image: UIImage(systemName: "rectangle.grid.2x2"),
                selectedImage: UIImage(systemName: "rectangle.grid.2x2.fill")
            )
            tabbarController.addChild(listController)
        }
        return rootViewController
    }
    
}


public final class TabBarController: UITabBarController {

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
// MARK: - Lifecycle

public extension TabBarController {

    func setupTabBar(viewController: UIViewController) {
        addChild(viewController)
    }

}

//
// 2/22/22
//
// Created by: Dominik Pethö
// Copyright © GoodRequest s.r.o. All rights reserved.

import Combine
import SafariServices
import MessageUI

// swiftlint:disable line_length enum_case_associated_values_count
public enum StepAction {

    case push(UIViewController, ignoreBackButtonTitle: Bool = false, animated: Bool = true)
    case pushWithCompletion(UIViewController, () -> Void)
    case dismissAndPresent(UIViewController, UIModalPresentationStyle, UIViewControllerTransitioningDelegate? = nil, Bool = true)
    case present(UIViewController, UIModalPresentationStyle, UIViewControllerTransitioningDelegate? = nil, Bool = true)
    case safari(URL)
    case dismiss
    case dismissWithCompletion(() -> Void)
    case pop
    case popAndPush(UIViewController)
    case popTo(UIViewController)
    case popToRoot
    case set([UIViewController])
    case none

    var isModalAction: Bool {
        switch self {
        case .present, .dismiss, .safari, .dismissAndPresent, .dismissWithCompletion:
            return true

        default:
            return false
        }
    }

    var isNavigationAction: Bool {
        switch self {
        case .push, .pushWithCompletion, .pop, .popTo, .set, .popToRoot, .popAndPush:
            return true

        default:
            return false
        }
    }

}

class Coordinator: GoodCoordinator<AppStep>,
                                       MFMailComposeViewControllerDelegate,
                                       MFMessageComposeViewControllerDelegate {

    typealias Step = AppStep
    public weak var rootViewController: UIViewController?

    public var rootNavigationController: UINavigationController? {
        return rootViewController as? UINavigationController
    }

    public init(rootViewController: UIViewController? = nil, parentCoordinator: GoodCoordinator<Step>? = nil) {
        super.init(parentCoordinator: parentCoordinator)

        self.rootViewController = rootViewController
    }

    @discardableResult
    open func navigate(to step: Step) -> StepAction {
        return .none
    }

    public func reset(animated: Bool) {
        if let presentedController = rootViewController?.presentedViewController {
            presentedController.dismiss(animated: animated) {
                self.rootNavigationController?.popToRootViewController(animated: animated)
            }
        } else {
            rootNavigationController?.popToRootViewController(animated: animated)
        }
    }

    private func navigate(flowAction: StepAction) {
        if flowAction.isModalAction {
            guard let viewController = rootViewController else {
                assertionFailure("Coordinator without root view controller")
                return
            }

            switch flowAction {
            case .dismiss:
                viewController.dismiss(animated: true, completion: nil)

            case .present(let controller, let style, let transitionDelegate, let animated):
                if let transitionDelegate = transitionDelegate {
                    controller.transitioningDelegate = transitionDelegate
                }
                controller.modalPresentationStyle = style
                viewController.present(controller, animated: animated, completion: nil)

            case .dismissAndPresent(let controller, let style, let transitionDelegate, let animated):
                if let transitionDelegate = transitionDelegate {
                    controller.transitioningDelegate = transitionDelegate
                }
                controller.modalPresentationStyle = style
                viewController.dismiss(animated: animated) {
                    viewController.present(controller, animated: animated, completion: nil)
                }

            case .dismissWithCompletion(let completion):
                viewController.dismiss(animated: true, completion: completion)

            case .safari(let url):
                let safariViewController = SFSafariViewController(url: url)
                return viewController.present(safariViewController, animated: true, completion: nil)
            default:
                break
            }
        } else if flowAction.isNavigationAction == true {
            guard let viewController = rootNavigationController else {
                assertionFailure("Coordinator without navigation view controller")
                return
            }

            switch flowAction {
            case .push(let controller, let ignoreBackButtonTitle, let animated):
                if  ignoreBackButtonTitle {
                    viewController.navigationBar.topItem?.title = " "
                }
                viewController.pushViewController(controller, animated: animated)

            case .pop:
                viewController.popViewController(animated: true)

            case let .popAndPush(controller):
                viewController.popViewController(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    viewController.pushViewController(controller, animated: true)
                }

            case .popTo(let controller):
                viewController.popToViewController(controller, animated: true)

            case .popToRoot:
                rootNavigationController?.popToRootViewController(animated: true)

            case .set(let controllers):
                viewController.setViewControllers(controllers, animated: true)

            default:
                break
            }
        }
    }

    @discardableResult
    open func start() -> UIViewController? {
        $step
            .compactMap { $0 }
            .sink { [weak self] in
                guard let `self` = self else { return }
                if let step = $0 as? Step {
                    self.navigate(flowAction: self.navigate(to: step))
                } else {
                    assertionFailure("Current step [\($0)] not available in the coordinator \(String(describing: self))")
                }
            }.store(in: &cancellables)

        return rootViewController
    }

    public func perform(step: Step) {
        self.step = step
    }

    // MARK: - MFMailComponseViewDelegate

    public func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }

    // MARK: - MFMessageComposeViewControllerDelegate

    public func messageComposeViewController(
        _ controller: MFMessageComposeViewController,
        didFinishWith result: MessageComposeResult
    ) {
        controller.dismiss(animated: true)
    }

}
