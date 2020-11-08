//
//  BuildingAttributeSearchViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 18/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearch

class BuildingAttributeSearchViewController<Attribute: Codable & CustomStringConvertible>: UIViewController {
  
  let searchController: UISearchController
  let searcher: SingleIndexSearcher
  let queryInputConnector: QueryInputConnector
  let queryInputController: TextFieldController
  let hitsConnector: HitsConnector<Attribute>
  let hitsController: BuildingAttributeHitsViewController<Attribute>
  
  convenience init(indexName: IndexName) {
    self.init(appID: .cityWallsAppID, apiKey: .cityWallsApiKey, indexName: indexName)
  }
  
  init(appID: ApplicationID, apiKey: APIKey, indexName: IndexName) {
    hitsController = .init()
    searchController = .init(searchResultsController: hitsController)
    searcher = .init(appID: appID, apiKey: apiKey, indexName: indexName)
    queryInputController = .init(searchBar: searchController.searchBar)
    queryInputConnector = .init(searcher: searcher, controller: queryInputController)
    hitsConnector = .init(searcher: searcher, controller: hitsController)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    title = "Стиль"
    searchController.isActive = true
    searchController.showsSearchResultsController = true
    searchController.automaticallyShowsSearchResultsController = false
    searchController.hidesNavigationBarDuringPresentation = false
    navigationItem.searchController = searchController
    searcher.search()
  }
  
}

