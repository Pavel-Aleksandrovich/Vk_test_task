//
//  SceneDelegate.swift
//  Vk_test_task
//
//  Created by pavel mishanin on 25/3/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let rootVC = InputDataViewController()
        let nav = UINavigationController(rootViewController: rootVC)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
}

