//
//  SceneDelegate.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import UIKit
import Combine

struct ColorScheme {
  static let tintColor = UIColor(red: 253/255, green: 184/255, blue: 19/255, alpha: 1)
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  var toolbarDelegate = ToolbarDelegate()
  let searchViewModel = SearchViewModel()
  private var showFilterSubscriber: AnyCancellable?
  lazy var filtersHelper = FiltersHelper(searchViewModel: searchViewModel)

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
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
      windowScene.title = "Санкт-Петербург"
    }
    #endif


    UIToolbar.appearance().tintColor = ColorScheme.tintColor
    window?.tintColor = ColorScheme.tintColor
    window?.rootViewController = SceneDelegate.buildRootViewController(searchViewModel: searchViewModel, filterHelper: filtersHelper)
    window?.makeKeyAndVisible()

    showFilterSubscriber = NotificationCenter.default.publisher(for: .showFilters)
          .receive(on: RunLoop.main)
          .sink(receiveValue: { [weak self] notification in
              guard let self = self else { return }
            self.filtersHelper.presentFilters()
          })
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }
  
}

extension SceneDelegate {
  
  static func buildRootViewController(searchViewModel: SearchViewModel, filterHelper: FiltersHelper) -> UIViewController {
    let mapHitsViewController = buildHitsMapViewController(searchViewModel: searchViewModel)
    let listHitsViewController = buildHitsListViewController(searchViewModel: searchViewModel)
    if UIDevice.current.userInterfaceIdiom == .phone {
      return buildRootPhoneViewController(listHitsViewController: listHitsViewController, mapHitsViewController: mapHitsViewController, searchViewModel: searchViewModel, filterHelper: filterHelper)
    } else {
      return buildRootPadViewController(listHitsViewController: listHitsViewController, mapHitsViewController: mapHitsViewController, searchViewModel: searchViewModel, filterHelper: filterHelper)
    }
  }
  
  static func buildHitsMapViewController(searchViewModel: SearchViewModel) -> BuldingHitsMapViewController {
    let mapHitsViewController = BuldingHitsMapViewController()
    mapHitsViewController.mapView.showsUserLocation = true
    mapHitsViewController.didChangeVisibleRegion = { [weak searchViewModel, weak mapHitsViewController] visibleRect, byUser in
      guard let searchViewModel = searchViewModel, byUser else { return }
      if let centerCoordinate = mapHitsViewController?.mapView.centerCoordinate {
        searchViewModel.searcher.indexQueryState.query.aroundLatLng = .init(.init(centerCoordinate))
      }
      searchViewModel.searcher.indexQueryState.query.aroundRadius = .all
      searchViewModel.searcher.search()
    }
    searchViewModel.hitsConnector.connectController(mapHitsViewController)
    return mapHitsViewController
  }
  
  static func buildHitsListViewController(searchViewModel: SearchViewModel) -> BuldingHitsListViewController {
    let listHitsViewController = BuldingHitsListViewController()
    listHitsViewController.tableView.keyboardDismissMode = .onDrag
    searchViewModel.hitsConnector.connectController(listHitsViewController)
    return listHitsViewController
  }
    
}

