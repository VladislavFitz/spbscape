//
//  MasterSearchViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 08/11/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearch
import CityWallsCore

class MasterSearchViewController: UIViewController {
  
  let queryInputConnector: QueryInputConnector
  let queryInputController: TextFieldController

  let searchController: UISearchController
  let hitsConnector: MultiIndexHitsConnector
  
  let filterState: FilterState

  let buildingHitsController: BuldingHitsListViewController
  let architectHitsController: BuildingAttributeHitsViewController<Architect>
  let streetHitsController: BuildingAttributeHitsViewController<Street>
  let styleHitsController: BuildingAttributeHitsViewController<Style>
  
  var currentScopeViewController: UIViewController?

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    let buildingHitsInteractor = HitsInteractor<Building>()
    let architectHitsInteractor = HitsInteractor<Architect>()
    let streetHitsInteractor = HitsInteractor<Street>()
    let styleHitsInteractor = HitsInteractor<Style>()
    
    buildingHitsController = .init()
    architectHitsController = .init()
    streetHitsController = .init()
    styleHitsController = .init()
    
    filterState = .init()
    
    hitsConnector = .init(appID: .cityWallsAppID, apiKey: .cityWallsApiKey, indexModules: [
      .init(indexName: .buildings, hitsInteractor: buildingHitsInteractor, filterState: filterState),
      .init(indexName: .architects, hitsInteractor: architectHitsInteractor),
      .init(indexName: .streets, hitsInteractor: streetHitsInteractor),
      .init(indexName: .styles, hitsInteractor: styleHitsInteractor),
    ])
    
    searchController = UISearchController(searchResultsController: nil)
    queryInputController = .init(searchBar: searchController.searchBar)
    queryInputConnector = .init(searcher: hitsConnector.searcher, controller: queryInputController)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    buildingHitsController.view.translatesAutoresizingMaskIntoConstraints = false
    architectHitsController.view.translatesAutoresizingMaskIntoConstraints = false
    streetHitsController.view.translatesAutoresizingMaskIntoConstraints = false
    styleHitsController.view.translatesAutoresizingMaskIntoConstraints = false
    
    buildingHitsInteractor.connectController(buildingHitsController)
    architectHitsInteractor.connectController(architectHitsController)
    streetHitsInteractor.connectController(streetHitsController)
    styleHitsInteractor.connectController(styleHitsController)
    
//    buildingHitsController.mapHitsViewController.didChangeVisibleRegion = { region in
//      let searcher = self.hitsConnector.searcher
//      searcher.indexQueryStates[0].query.insideBoundingBox = [BoundingBox(region)]
//      searcher.search()
//    }
    
//    hitsConnector.searcher.indexQueryStates[0].query.hitsPerPage = 1000

  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.obscuresBackgroundDuringPresentation = false
    navigationItem.hidesSearchBarWhenScrolling = false
    navigationItem.searchController = searchController
    searchController.searchBar.scopeButtonTitles = ["Здания", "Архитекторы", "Улицы", "Стили"]
    searchController.searchBar.delegate = self
    setCurrentScope(buildingHitsController)
    queryInputConnector.searcher.search()
    title = "Санкт-Петербург"
  }
  
  func setCurrentScope(_ viewController: UIViewController) {
    currentScopeViewController?.view.removeFromSuperview()
    currentScopeViewController?.removeFromParent()
    currentScopeViewController = viewController
    addChild(viewController)
    viewController.didMove(toParent: self)
    view.addSubview(viewController.view)
    activate(
      viewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      viewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      viewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
    )
  }
  
}

extension MasterSearchViewController: UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    let mode = FilterMode.allCases[selectedScope]
    let viewController: UIViewController
    switch mode {
    case .allBuildings:
      viewController = buildingHitsController
    case .architect:
      viewController = architectHitsController
    case .street:
      viewController = streetHitsController
    case .style:
      viewController = styleHitsController
    }
    setCurrentScope(viewController)
  }
  
}
