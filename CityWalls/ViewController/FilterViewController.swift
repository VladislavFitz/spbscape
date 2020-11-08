//
//  FilterViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 17/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import InstantSearch

class FilterViewController: UIViewController {
  
  let mainStackView: UIStackView
  let pageStackView: UIStackView
  
  let architectFacetSearcher: FacetSearcher
  let architectFacetConnector: FacetListConnector
  let architectFacetController: FacetListTableController
  let architectTableViewController: UITableViewController = .init(style: .plain)

  let streetFacetSearcher: FacetSearcher
  let streetFacetConnector: FacetListConnector
  let streetFacetController: FacetListTableController
  let streetTableViewController: UITableViewController = .init(style: .plain)

  let styleFacetSearcher: FacetSearcher
  let styleFacetConnector: FacetListConnector
  let styleFacetController: FacetListTableController
  let styleTableViewController: UITableViewController = .init(style: .plain)

  let queryInputConnector: QueryInputConnector
  let queryInputController: TextFieldController
  let searchBar: UISearchBar

  init(filterState: FilterState) {
    searchBar = .init()
    mainStackView = .init()
    pageStackView = .init()
    architectFacetSearcher = FacetSearcher(appID: .cityWallsAppID, apiKey: .cityWallsApiKey, indexName: .buildings, facetName: "architects.title")
    streetFacetSearcher = FacetSearcher(appID: .cityWallsAppID, apiKey: .cityWallsApiKey, indexName: .buildings, facetName: "addresses.title")
    styleFacetSearcher = FacetSearcher(appID: .cityWallsAppID, apiKey: .cityWallsApiKey, indexName: .buildings, facetName: "styles.title")
    queryInputController = .init(searchBar: searchBar)
    queryInputConnector = .init(searcher: streetFacetSearcher, controller: queryInputController)
    queryInputConnector.interactor.connectSearcher(architectFacetSearcher)
    queryInputConnector.interactor.connectSearcher(styleFacetSearcher)
    
    architectFacetController = .init(tableView: architectTableViewController.tableView)
    streetFacetController = .init(tableView: streetTableViewController.tableView)
    styleFacetController = .init(tableView: styleTableViewController.tableView)
    architectFacetConnector = .init(searcher: architectFacetSearcher, attribute: "architects.title", operator: .or, controller: architectFacetController)
    streetFacetConnector = .init(searcher: streetFacetSearcher, attribute: "addresses.title", operator: .or, controller: styleFacetController)
    styleFacetConnector = .init(searcher: styleFacetSearcher, attribute: "styles.title", operator: .or, controller: architectFacetController)
    super.init(nibName: nil, bundle: nil)
    architectFacetSearcher.connectFilterState(filterState)
    streetFacetSearcher.connectFilterState(filterState)
    styleFacetSearcher.connectFilterState(filterState)

    
  }
    
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.axis = .vertical
    pageStackView.translatesAutoresizingMaskIntoConstraints = false
    pageStackView.axis = .horizontal
    searchBar.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(mainStackView)
    title = "Фильтры"
    activate(
      mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    )
    [architectTableViewController, streetTableViewController, styleTableViewController]
      .map(\.tableView)
      .compactMap({ $0 })
      .forEach { view in
        view.translatesAutoresizingMaskIntoConstraints = false
        pageStackView.addArrangedSubview(view)
    }
    mainStackView.addArrangedSubview(searchBar)
    mainStackView.addArrangedSubview(pageStackView)
    architectTableViewController.tableView.isHidden = false
    streetTableViewController.tableView.isHidden = true
    styleTableViewController.tableView.isHidden = true
  }
  
}
