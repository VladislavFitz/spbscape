//
//  GlobalSearchViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 18/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearch
import CityWallsCore

class GlobalSearchViewController: UIViewController {
  
  let queryInputConnector: QueryInputConnector
  let queryInputController: TextFieldController

  let searchController: UISearchController
  let hitsConnector: MultiIndexHitsConnector
  
  let filterState: FilterState
  
  var currentScopeViewController: UIViewController?
  
  let buildingHitsController: SegmentedBuildingHitsController
  let architectHitsController: BuildingAttributeHitsViewController<Architect>
  let streetHitsController: BuildingAttributeHitsViewController<Street>
  let styleHitsController: BuildingAttributeHitsViewController<Style>

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
    
    buildingHitsController.mapHitsViewController.didChangeVisibleRegion = { region in
      let searcher = self.hitsConnector.searcher
      searcher.indexQueryStates[0].query.insideBoundingBox = [BoundingBox(region)]
      searcher.search()
    }
    
    hitsConnector.searcher.indexQueryStates[0].query.hitsPerPage = 1000

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
    searchController.searchBar.showsScopeBar = true
    searchController.searchBar.scopeButtonTitles = ["Здания", "Архитекторы", "Улицы", "Стили"]
    searchController.searchBar.delegate = self
    setCurrentScope(buildingHitsController)
    queryInputConnector.searcher.search()
    
    title = "CityWalls"
    
    buildingHitsController.didSelect = { [weak self] building in
      let buildingViewController = BuildingViewController(building: building)
      self?.present(buildingViewController, animated: true, completion: nil)
    }
    
    architectHitsController.didSelect = { [weak self] architect in
      guard let vc = self else { return }
      let bvc = BuildingSearchViewController()
      bvc.filterState[and: "g"].add(Filter.Facet(attribute: "architects.id", stringValue: "\(architect.id)"))
      bvc.filterState.notifyChange()
      bvc.searcher.search()
      vc.navigationController?.pushViewController(bvc, animated: true)
    }
    
    streetHitsController.didSelect = { [weak self] street in
      guard let vc = self else { return }
      let bvc = BuildingSearchViewController()
      bvc.filterState[and: "g"].add(Filter.Facet(attribute: "addresses.id", stringValue: "\(street.id)"))
      bvc.filterState.notifyChange()
      bvc.searcher.search()
      vc.navigationController?.pushViewController(bvc, animated: true)
    }
    
    styleHitsController.didSelect = { [weak self] (style: Style) in
      guard let vc = self else { return }
      let bvc = BuildingSearchViewController()
      bvc.filterState[and: "g"].add(Filter.Facet(attribute: "styles.id", stringValue: "\(style.id)"))
      bvc.filterState.notifyChange()
      bvc.searcher.search()
      vc.navigationController?.pushViewController(bvc, animated: true)
    }
          
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

extension GlobalSearchViewController: UISearchBarDelegate {
  
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

extension Style: CustomStringConvertible {
  
  public var description: String {
    name
  }
  
}
