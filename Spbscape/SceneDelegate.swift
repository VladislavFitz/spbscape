//
//  SceneDelegate.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import AlgoliaSearchClient
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  let coordinator: Coordinator = {
    if UIDevice.current.userInterfaceIdiom == .phone {
      PhoneCoordinator()
    } else {
      PadCoordinator()
    }
  }()

  func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(frame: windowScene.coordinateSpace.bounds)
    window?.windowScene = windowScene
    window?.tintColor = ColorScheme.primaryColor
    window?.rootViewController = coordinator.rootViewController()
    window?.makeKeyAndVisible()
    coordinator.presentRoot()
    UIToolbar.appearance().tintColor = ColorScheme.primaryColor
    #if targetEnvironment(macCatalyst)
    if let titlebar = windowScene.titlebar {
      titlebar.titleVisibility = .visible
      titlebar.toolbar = (coordinator as? PadCoordinator)?.toolbar
      titlebar.toolbarStyle = .automatic
    }
    windowScene.title = "saint-petersburg".localize()
    #endif
  }
}

extension SceneDelegate {}
