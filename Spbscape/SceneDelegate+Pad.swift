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
    mapHitsViewController.navigationController?.isNavigationBarHidden = true
    
    _ = mapHitsViewController.floatingPanel
    searchViewModel.searcher.onResults.subscribePast(with: searchViewController) { (vc, response) in
      let hitsCountText = "\("buildings".localize()): \(response.searchStats.totalHitsCount)"
      mapHitsViewController.hitsCountLabel.text = hitsCountText
    }.onQueue(.main)
    mapHitsViewController.filterButton.addTarget(searchViewController,
                                                 action: #selector(searchViewController.didTapFilterButton(_:)),
                                                 for: .touchUpInside)

    searchViewController.didTapFilterButton = { _ in
      filterHelper.sourceRect = mapHitsViewController.view.convert(mapHitsViewController.filterButton.frame,
                                                                   from: mapHitsViewController.floatingPanel.stackView)
      filterHelper.presentFilters(showHitsCount: false)
    }

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
