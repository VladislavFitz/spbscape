//
//  FilterViewController.swift
//  Spbscape
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
  
  let multiSearcher: MultiSearcher
  
  init(filterState: FilterState, hitsCountBarButtonItem: UIBarButtonItem) {
    
    self.multiSearcher = MultiSearcher(appID: .spbscapeAppID, apiKey: .spbscape)
    self.filterState = filterState
    self.hitsCountBarButtonItem = hitsCountBarButtonItem
    
    let viewControllers: [FacetListViewController] = FilterSection.allCases.map { _ in .init(style: .plain) }
    
    resultsViewController = ContainerViewController(viewControllers: viewControllers)
    searchController = UISearchController(searchResultsController: nil)
    
    let queryInputInteractor = QueryInputInteractor()
    queryInputController = .init(searchBar: searchController.searchBar)
    queryInputInteractor.connectSearcher(multiSearcher)
    queryInputInteractor.connectController(queryInputController)
    
    facetListConnectors = zip(FilterSection.allCases.map(\.attribute), viewControllers).map { [unowned multiSearcher] attribute, viewController in
      let facetSearcher = multiSearcher.addFacetsSearcher(indexName: .buildings,
                                                          attribute: attribute)
      let facetListConnector = FacetListConnector(searcher: facetSearcher,
                                                  filterState: filterState,
                                                  attribute: attribute,
                                                  operator: .or,
                                                  controller: viewController)
      facetSearcher.connectFilterState(filterState)
      return facetListConnector
    }
    
    self.queryInputInteractor = queryInputInteractor
    
    super.init(nibName: nil, bundle: nil)
    navigationItem.searchController = searchController
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(dismissViewController))
    let clearFiltersBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .done, target: self, action: #selector(resetFilters))
    toolbarItems = [
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      hitsCountBarButtonItem,
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      clearFiltersBarButtonItem
    ]
    filterState.onChange.subscribePast(with: self) { (vc, filters) in
      let hasAppliedFilter = !FilterSection.allCases
        .map(\.attribute.rawValue)
        .map { vc.filterState[or: $0] as OrGroupAccessor<Filter.Facet> }
        .map(\.isEmpty)
        .allSatisfy { $0 }
      clearFiltersBarButtonItem.isEnabled = hasAppliedFilter
    }.onQueue(.main)
    
    let hasAppliedFilter = !FilterSection.allCases
      .map(\.attribute.rawValue)
      .map { filterState[or: $0] as OrGroupAccessor<Filter.Facet> }
      .map(\.isEmpty)
      .allSatisfy { $0 }
    
    clearFiltersBarButtonItem.isEnabled = hasAppliedFilter
    
    addChild(resultsViewController)
    resultsViewController.didMove(toParent: self)
  }
    
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Фильтры"
    view.backgroundColor = .systemBackground
    navigationController?.isToolbarHidden = false

    searchController.hidesNavigationBarDuringPresentation = false
    searchController.searchBar.showsScopeBar = true
    searchController.isActive = true
    searchController.searchBar.showsCancelButton = false
    searchController.searchBar.scopeButtonTitles = FilterSection.allCases.map(\.title)
    searchController.searchBar.delegate = self
    
    view.addSubview(resultsViewController.view)
    resultsViewController.view.pin(to: view)
    
    queryInputInteractor.onQueryChanged.fire(nil)
  }
    
  @objc private func resetFilters() {
    (filterState[or: FilterSection.architect.attribute.rawValue] as OrGroupAccessor<Filter.Facet>).removeAll()
    (filterState[or: FilterSection.style.attribute.rawValue] as OrGroupAccessor<Filter.Facet>).removeAll()
    (filterState[or: FilterSection.street.attribute.rawValue] as OrGroupAccessor<Filter.Facet>).removeAll()
    filterState.notifyChange()
  }
  
  @objc private func dismissViewController() {
    navigationController?.dismiss(animated: true, completion: nil)
  }
  
}

extension FilterViewController: UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    resultsViewController.setVisibleViewController(atIndex: selectedScope)
  }
  
}

