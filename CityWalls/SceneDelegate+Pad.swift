//
//  SceneDelegate+Pad.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 21/03/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

extension SceneDelegate {
  
  static func buildRootPadViewController(listHitsViewController: BuldingHitsListViewController,
                                         mapHitsViewController: BuldingHitsMapViewController,
                                         searchViewModel: SearchViewModel,
                                         filterHelper: FiltersHelper) -> UIViewController {
    
    filterHelper.sourceViewController = mapHitsViewController
    
    let sidebarViewController = SidebarViewConttroller(contentController: listHitsViewController)
    searchViewModel.configure(sidebarViewController.searchBar)
        
    let splitViewController: UISplitViewController
    if #available(macCatalyst 14.0, iOS 14.0, *) {
      splitViewController = UISplitViewController(style: .doubleColumn)
      splitViewController.primaryBackgroundStyle = .sidebar
      splitViewController.presentsWithGesture = false
      splitViewController.preferredDisplayMode = .allVisible
      splitViewController.setViewController(sidebarViewController, for: .primary)
      splitViewController.setViewController(mapHitsViewController, for: .secondary)
    } else {
      splitViewController = .init()
      splitViewController.viewControllers = [
        UINavigationController(rootViewController: sidebarViewController),
        UINavigationController(rootViewController: mapHitsViewController)
      ]
    }
    
    // For macOS a system toolbar presented, for iPadOS a classic navigation bar
    #if targetEnvironment(macCatalyst)
    mapHitsViewController.navigationController?.isNavigationBarHidden = true
    #else
    
    mapHitsViewController.navigationItem.rightBarButtonItems = [
      splitViewController.displayModeButtonItem,
      filterHelper.filterBarButtonItem,
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      searchViewModel.hitsCountBarButtonItem()
    ]
    #endif
    
    listHitsViewController.didSelect = { [weak mapHitsViewController] building in
      mapHitsViewController?.highlight(building)
    }
    
    mapHitsViewController.didSelect = { [weak mapHitsViewController] building, view in
      mapHitsViewController?.presentPopover(for: building, from: view)
    }

    
    searchViewModel.searcher.search()
    return splitViewController
  }
  
}
