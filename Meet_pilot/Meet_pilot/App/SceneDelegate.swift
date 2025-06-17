//
//  SceneDelegate.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/11/25.
//

import UIKit
import RxFlow
import RxSwift
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    let appCoordinator = FlowCoordinator()
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let scene = (scene as? UIWindowScene) else { return }

        let vm = MainViewModel()
        let main = MainViewController()
        
        let login = LoginViewController()
        login.reactor = LoginViewModel()
        
        main.reactor = vm
        let nav = UINavigationController(rootViewController: login)
        
        window = UIWindow(windowScene: scene)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
             let _ = GIDSignIn.sharedInstance.handle(url)
    }
}

