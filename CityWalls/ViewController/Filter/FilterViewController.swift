//
//  FilterViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 17/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearch

class FilterViewController: UIViewController {
  
  let searchController: UISearchController
  let filterState: FilterState
  
  let facetListConnectors: [FacetListConnector]

  let queryInputInteractor: QueryInputInteractor
  let queryInputController: TextFieldController
  
  let resultsViewController: ContainerViewController
  
  let hitsCountBarButtonItem: UIBarButtonItem
  
  init(filterState: FilterState) {
    
    self.filterState = filterState
    hitsCountBarButtonItem = .init(title: "Результатов: 0", style: .done, target: nil, action: nil)
    
    let viewControllers: [UITableViewController] = FilterSection.allCases.map { _ in .init(style: .plain) }
    
    resultsViewController = ContainerViewController(viewControllers: viewControllers)
    searchController = UISearchController(searchResultsController: resultsViewController)
    
    let queryInputInteractor = QueryInputInteractor()
    queryInputController = .init(searchBar: searchController.searchBar)
    queryInputInteractor.connectController(queryInputController)

    facetListConnectors = zip(FilterSection.allCases.map(\.attribute), viewControllers).map { attribute, viewController in
      let facetSearcher = FacetSearcher(appID: .cityWallsAppID, apiKey: .cityWallsApiKey, indexName: .buildings, facetName: attribute.rawValue)
      let facetListController = FacetListTableController(tableView: viewController.tableView)
      let facetListConnector = FacetListConnector(searcher: facetSearcher, filterState: filterState, attribute: attribute, operator: .or, controller: facetListController)
      facetSearcher.connectFilterState(filterState)
      queryInputInteractor.connectSearcher(facetSearcher)
      return facetListConnector
    }
    
    self.queryInputInteractor = queryInputInteractor
    
    super.init(nibName: nil, bundle: nil)
    navigationItem.searchController = searchController
    let resetBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle"), style: .done, target: self, action: #selector(resetFilters))
    toolbarItems = [
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      hitsCountBarButtonItem,
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      resetBarButtonItem
    ]

  }
    
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Фильтры"
    view.backgroundColor = .systemBackground
    searchController.searchBar.showsScopeBar = true
    searchController.automaticallyShowsSearchResultsController = false
    searchController.showsSearchResultsController = true
    searchController.isActive = true
    searchController.searchBar.showsCancelButton = false
    searchController.searchBar.scopeButtonTitles = FilterSection.allCases.map(\.title)
    searchController.searchBar.delegate = self
    queryInputInteractor.onQueryChanged.fire(nil)
    
    navigationController?.isToolbarHidden = false
  }
  
  @objc private func resetFilters() {
    (filterState[or: FilterSection.architect.attribute.rawValue] as OrGroupAccessor<Filter.Facet>).removeAll()
    (filterState[or: FilterSection.style.attribute.rawValue] as OrGroupAccessor<Filter.Facet>).removeAll()
    (filterState[or: FilterSection.street.attribute.rawValue] as OrGroupAccessor<Filter.Facet>).removeAll()
    filterState.notifyChange()
  }
  
}

extension FilterViewController: UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    resultsViewController.setVisibleViewController(atIndex: selectedScope)
  }
  
}
