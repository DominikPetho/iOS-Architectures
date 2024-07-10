//
//  SceneDeleaget.swift
//  Sample App 1
//
//  Created by Dominik Pethö on 10/07/2024.
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }


        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = MainCoordinator(rootViewController: UINavigationController()).start()
        self.window = window
        window.makeKeyAndVisible()
    }

}
