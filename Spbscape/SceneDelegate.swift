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
    window?.rootViewController = SceneDelegate.buildRootViewController(searchViewModel: searchViewModel)
    window?.makeKeyAndVisible()
  }
  
}

extension SceneDelegate {
  
  static func buildRootViewController(searchViewModel: SearchViewModel) -> UIViewController {
    let mapHitsViewController = buildHitsMapViewController(searchViewModel: searchViewModel)
    let listHitsViewController = buildHitsListViewController(searchViewModel: searchViewModel)
    if UIDevice.current.userInterfaceIdiom == .phone {
      return buildRootPhoneViewController(listHitsViewController: listHitsViewController,
                                          mapHitsViewController: mapHitsViewController, searchViewModel: searchViewModel)
    } else {
      return buildRootPadViewController(listHitsViewController: listHitsViewController, mapHitsViewController: mapHitsViewController, searchViewModel: searchViewModel)
    }
  }
  
  static func buildHitsMapViewController(searchViewModel: SearchViewModel) -> BuldingHitsMapViewController {
    let mapHitsViewController = BuldingHitsMapViewController()
    mapHitsViewController.mapView.showsUserLocation = true
    mapHitsViewController.didChangeVisibleRegion = { [weak searchViewModel, weak mapHitsViewController] visibleRect, byUser in
      guard let searchViewModel = searchViewModel, byUser else { return }
      if let mapView = mapHitsViewController?.mapView {
        searchViewModel.searcher.request.query.aroundPrecision = [.init(from: 0, value: mapView.region.sizeInMeters.h)]
        searchViewModel.searcher.request.query.aroundLatLng = Point(mapView.centerCoordinate)
      }
      searchViewModel.searcher.request.query.aroundRadius = .all
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
