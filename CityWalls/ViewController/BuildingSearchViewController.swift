//
//  BuildingSearchViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 17/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearch
import CityWallsCore

class BuildingSearchViewController: UIViewController {
  
  let searcher: SingleIndexSearcher
  let queryInputConnector: QueryInputConnector
  let queryInputController: TextFieldController
  
  let filterState: FilterState
  
  let searchController: UISearchController
  let hitsConnector: HitsConnector<Building>
  let hitsController: SegmentedBuildingHitsController
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    searcher = .init(appID: .cityWallsAppID, apiKey: .cityWallsApiKey, indexName: .buildings)
    filterState = .init()
    hitsController = .init()
    searchController = UISearchController(searchResultsController: nil)
    queryInputController = .init(searchBar: searchController.searchBar)
    queryInputConnector = .init(searcher: searcher, controller: queryInputController)
    hitsConnector = .init(searcher: searcher, filterState: filterState, controller: hitsController)
        
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    searcher.connectFilterState(filterState)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    title = "Дома"
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    searcher.search()
    addChild(hitsController)
    hitsController.willMove(toParent: self)
    view.addSubview(hitsController.view)
    hitsController.view.translatesAutoresizingMaskIntoConstraints = false
    activate(
      hitsController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hitsController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      hitsController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hitsController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    )
  }
  
  @objc func presentFilters() {
    let filtersViewController = FilterViewController(filterState: filterState)
    let filtersNavigationController = UINavigationController(rootViewController: filtersViewController)
    present(filtersNavigationController, animated: true, completion: nil)
  }
  
}

