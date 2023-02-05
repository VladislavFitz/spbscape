//
//  SceneDelegate+Pad.swift
//  Spbscape
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
    
    let searchViewController = SearchViewController(childViewController: listHitsViewController,
                                                    style: .fullscreen)
    searchViewController.handleView.handleBar.isHidden = true
    searchViewController.hitsCountView.isHidden = true
    searchViewController.filterButton.isHidden = true
    searchViewModel.configure(searchViewController.searchTextField)
        
    let splitViewController: UISplitViewController
    if #available(macCatalyst 14.0, iOS 14.0, *) {
      splitViewController = UISplitViewController(style: .doubleColumn)
      splitViewController.primaryBackgroundStyle = .sidebar
      splitViewController.presentsWithGesture = false
      splitViewController.preferredDisplayMode = .allVisible
      splitViewController.setViewController(searchViewController, for: .primary)
      splitViewController.setViewController(mapHitsViewController, for: .secondary)
    } else {
      splitViewController = UISplitViewController()
      splitViewController.viewControllers = [
        searchViewController,
        UINavigationController(rootViewController: mapHitsViewController)
      ]
    }

    // For macOS a system toolbar presented, for iPadOS a classic navigation bar
    #if targetEnvironment(macCatalyst)
    searchViewController.handleView.isHidden = true
    searchViewController.navigationController?.isNavigationBarHidden = true
    #else
    searchViewController.navigationController?.isNavigationBarHidden = true
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
      guard let mapHitsViewController = mapHitsViewController else { return }
      mapHitsViewController.presentSidebar(for: building)
    }

    
    searchViewModel.searcher.search()
    return splitViewController
  }
  
}
