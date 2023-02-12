//
//  SceneDelegate.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import UIKit
import AlgoliaSearchClient

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  var toolbarDelegate = ToolbarDelegate()
  let searchViewModel = SearchViewModel()
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(frame: windowScene.coordinateSpace.bounds)
    window?.windowScene = windowScene
    
#if targetEnvironment(macCatalyst)
    if #available(macCatalyst 14.0, *) {
      let toolbar = NSToolbar(identifier: "main")
      toolbar.delegate = toolbarDelegate
      toolbar.displayMode = .iconOnly
      if let titlebar = windowScene.titlebar {
        titlebar.titleVisibility = .visible
        titlebar.toolbar = toolbar
        titlebar.toolbarStyle = .automatic
      }
      windowScene.title = "saint-petersburg".localize()
    }
#endif
    
    UIToolbar.appearance().tintColor = ColorScheme.primaryColor
    window?.tintColor = ColorScheme.primaryColor
    window?.rootViewController = ViewControllerFactory.rootViewController(searchViewModel: searchViewModel)
    window?.makeKeyAndVisible()
    searchViewModel.searcher.search()
  }
  
}

extension SceneDelegate {
  

  
  
}
