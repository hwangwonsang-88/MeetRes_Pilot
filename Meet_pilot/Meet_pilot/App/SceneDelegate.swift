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

        window = UIWindow(windowScene: scene)
        
//        let appFlow = AppFlow(window: window!)
//        let appStepper = AppStepper()
//        
//        appCoordinator.coordinate(flow: appFlow, with: appStepper)
        
        
        let temp = MainViewController(datasource: MeetingRooms(data: [MeetingRoom(name: "임시", calendarID: "ㅇㅁㄴㄹ"),
                                                                      MeetingRoom(name: "임시2", calendarID: "ㅇㅁㄴㄹ"),
                                                                      MeetingRoom(name: "임시3", calendarID: "ㅇㅁㄴㄹ")]))
        
        temp.reactor = MainViewModel()
        
        let temp2 = CreateReservationViewController()
        window?.rootViewController = UINavigationController(rootViewController: temp2)
//        window?.rootViewController = UINavigationController(rootViewController: temp)
        window?.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
             let _ = GIDSignIn.sharedInstance.handle(url)
    }
}

