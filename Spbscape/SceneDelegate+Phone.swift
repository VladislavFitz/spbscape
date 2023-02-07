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
                                                    style: .overlay)
    let interactiveSheetViewController = InteractiveSheetViewController(mainViewController: mapHitsViewController,
                                                                        overlayViewController: searchViewController,
                                                                        compactHeight: searchViewController.compactHeight,
                                                                        searchTextField: searchViewController.searchTextField)
    searchViewController.didTapFilterButton = { _ in
      interactiveSheetViewController.presentFilters {
        let filtersViewController = FiltersViewController(showResultsCount: true)
        searchViewModel.setup(filtersViewController)
        return filtersViewController
      }
    }
    searchViewModel.setup(searchViewController)
    
    let navigationController = UINavigationController(rootViewController: interactiveSheetViewController)
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
