//
//  MainTabBarViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 17/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import CityWallsCore

extension Architect: CustomStringConvertible {
  
  public var description: String { name }
  
}

extension Street: CustomStringConvertible {
  
  public var description: String { title }
  
}

class MainTabBarViewController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
        
    let mapViewController = BuldingHitsMapViewController()
    mapViewController.tabBarItem = .init(title: "Карта", image: UIImage(systemName: "map"), tag: 0)
    
    let filterModePickerViewController = FilterModePickerViewController()
    filterModePickerViewController.didSelect = { mode in
      switch mode {
      case .allBuildings:
        let buildingListViewController = BuildingSearchViewController()
        filterModePickerViewController.navigationController?.pushViewController(buildingListViewController, animated: true)

      case .architect:
        let architectPickerViewController = BuildingAttributeSearchViewController<Architect>(indexName: .architects)
        filterModePickerViewController.navigationController?.pushViewController(architectPickerViewController, animated: true)
        
      case .street:
        let streetPickerViewController = BuildingAttributeSearchViewController<Street>(indexName: .streets)
        filterModePickerViewController.navigationController?.pushViewController(streetPickerViewController, animated: true)
        
      case .style:
        let stylePickerViewController = BuildingAttributeSearchViewController<Style>(indexName: .styles)
        filterModePickerViewController.navigationController?.pushViewController(stylePickerViewController, animated: true)
      }
    }
    let filterModePickerNavigationController = UINavigationController(rootViewController: filterModePickerViewController)
    filterModePickerNavigationController.tabBarItem = .init(title: "Список", image: UIImage(systemName: "magnifyingglass"), tag: 1)
    
    let globalSearchViewController = GlobalSearchViewController()
    let globalSearchNavigationController = UINavigationController(rootViewController: globalSearchViewController)
    globalSearchNavigationController.tabBarItem = .init(title: "Список", image: UIImage(systemName: "magnifyingglass"), tag: 1)
    
    viewControllers = [mapViewController, globalSearchNavigationController]
  }
  
}
