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
                                           searchViewModel: SearchViewModel) -> UIViewController {
    let searchViewController = SearchViewController(childViewController: listHitsViewController,
                                                    style: .overlay,
                                                    filterButton: searchViewModel.filtersButton())
    let phoneViewController = CompactViewController(mainViewController: mapHitsViewController,
                                                    overlayViewController: searchViewController,
                                                    compactHeight: searchViewController.compactHeight,
                                                    searchTextField: searchViewController.searchTextField)
    searchViewController.didTapFilterButton = { _ in      
      phoneViewController.presentFilters {
        let filtersViewController = FilterViewController(clearFiltersBarButtonItem: searchViewModel.clearFiltersBarButtonItem(),
                                                         hitsCountBarButtonItem: searchViewModel.hitsCountBarButtonItem())
        searchViewModel.filtersController.setup(filtersViewController)
        return filtersViewController
      }
    }
    searchViewModel.searcher.onResults.subscribePast(with: searchViewController) { (vc, response) in
      vc.setHitsCount(response.searchStats.totalHitsCount)
    }.onQueue(.main)
    
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
