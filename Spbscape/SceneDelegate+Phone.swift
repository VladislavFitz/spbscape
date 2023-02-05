//
//  SceneDelegate+Phone.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 21/03/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

extension SceneDelegate {
  
  static func buildRootPhoneViewController(listHitsViewController: BuldingHitsListViewController,
                                           mapHitsViewController: BuldingHitsMapViewController,
                                           searchViewModel: SearchViewModel,
                                           filterHelper: FiltersHelper) -> UIViewController {
    let searchViewController = SearchViewController(childViewController: listHitsViewController, style: .overlay)
    let phoneViewController = CompactViewController(mainViewController: mapHitsViewController,
                                                    overlayViewController: searchViewController,
                                                    compactHeight: searchViewController.compactHeight,
                                                    searchTextField: searchViewController.searchTextField)
    searchViewController.didTapFilterButton = { _ in
      filterHelper.presentFilters()
    }
    searchViewModel.searcher.onResults.subscribePast(with: searchViewController) { (vc, response) in
      vc.setHitsCount(response.searchStats.totalHitsCount)
    }.onQueue(.main)
    
    filterHelper.sourceViewController = phoneViewController
    searchViewModel.configure(searchViewController.searchTextField)
    let navigationController = UINavigationController(rootViewController: phoneViewController)    
    mapHitsViewController.didSelect = { [weak navigationController] building, _ in
      let buildingViewController = BuildingViewController(building: building)
      buildingViewController.view.backgroundColor = .systemBackground
      navigationController?.pushViewController(buildingViewController, animated: true)
    }
    
    listHitsViewController.didSelect = { [weak navigationController] building in
      let buildingViewController = BuildingViewController(building: building)
      buildingViewController.view.backgroundColor = .systemBackground
      navigationController?.pushViewController(buildingViewController, animated: true)
    }
    
    searchViewModel.searcher.search()
    return navigationController
  }
  
}
