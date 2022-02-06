//
//  SceneDelegate+Phone.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 21/03/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import BottomSheet

extension SceneDelegate {
  
  static func buildRootPhoneViewController(listHitsViewController: BuldingHitsListViewController,
                                           mapHitsViewController: BuldingHitsMapViewController,
                                           searchViewModel: SearchViewModel,
                                           filterHelper: FiltersHelper) -> UIViewController {
    
//    let unitViewController = CombinedHitsViewController(listViewController: listHitsViewController,
//                                                        mapViewController: mapHitsViewController)
//    let sidebarViewController = SidebarViewConttroller(contentController: unitViewController)
//    searchViewModel.configure(sidebarViewController.searchBar)
//    sidebarViewController.toolbarItems = [
//      unitViewController.switchAppearanceModeBarButtonItem,
//      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
//      searchViewModel.hitsCountBarButtonItem(),
//      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
//      filterHelper.filterBarButtonItem
//    ]
    
    let phoneViewController = PhoneViewController(listViewController: listHitsViewController,
                                                  mapViewController: mapHitsViewController)
    phoneViewController.overlayViewController.didTapFilterButton = { _ in
      filterHelper.presentFilters()
    }
    searchViewModel.searcher.onResults.subscribePast(with: phoneViewController.overlayViewController) { (vc, response) in
      vc.setHitsCount(response.searchStats.totalHitsCount)
    }.onQueue(.main)
    
    filterHelper.sourceViewController = phoneViewController
    searchViewModel.configure(phoneViewController.overlayViewController.searchTextField)
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
