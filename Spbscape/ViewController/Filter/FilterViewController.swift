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

final class FiltersController {
  
  let searcher: MultiSearcher
  let facetListConnectors: [FacetListConnector]
  let filterState: FilterState
  let queryInputInteractor: QueryInputInteractor
  
  init(filterState: FilterState) {
    self.filterState = filterState
    searcher = MultiSearcher(appID: .spbscapeAppID, apiKey: .spbscape)
    
    facetListConnectors = FilterSection.allCases.map { [unowned searcher] section in
      let facetSearcher = searcher.addFacetsSearcher(indexName: .buildings,
                                                     attribute: section.attribute)
      let facetListConnector = FacetListConnector(searcher: facetSearcher,
                                                  filterState: filterState,
                                                  attribute: section.attribute,
                                                  operator: .or)
      facetSearcher.connectFilterState(filterState)
      return facetListConnector
    }
    
    queryInputInteractor = QueryInputInteractor()
    queryInputInteractor.connectSearcher(searcher)
    
    queryInputInteractor.onQueryChanged.fire(nil)
  }
  
  func setup(_ filterViewController: FilterViewController) {
    queryInputInteractor.connectController(filterViewController.queryInputController)
    zip(facetListConnectors, filterViewController.viewControllers).forEach { connector, controller in
      connector.connectController(controller)
    }
  }
  
  
}

class FilterViewController: UIViewController {
  
  let searchController: UISearchController
  let queryInputController: TextFieldController
  let resultsViewController: SwitchContainerViewController
  let viewControllers: [FacetListViewController]
    
  init(clearFiltersBarButtonItem: UIBarButtonItem,
       hitsCountBarButtonItem: UIBarButtonItem?) {
    viewControllers = FilterSection.allCases.map { _ in FacetListViewController(style: .plain) }
    resultsViewController = SwitchContainerViewController(viewControllers: viewControllers)
    searchController = UISearchController(searchResultsController: nil)
    queryInputController = TextFieldController(searchBar: searchController.searchBar)
    
    super.init(nibName: nil, bundle: nil)
    navigationItem.searchController = searchController
    let closeBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle"),
                                             style: .done,
                                             target: self,
                                             action: #selector(dismissViewController))
    let additionalBarButtonItems = hitsCountBarButtonItem.flatMap { [
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      $0
    ] } ?? []
    
    toolbarItems =
    [clearFiltersBarButtonItem] +
    additionalBarButtonItems + [
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      closeBarButtonItem
    ]
    addChild(resultsViewController)
    resultsViewController.didMove(toParent: self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "filters".localize()
    view.backgroundColor = .systemBackground
    navigationController?.isToolbarHidden = false
    setupSearchController()
    view.addSubview(resultsViewController.view)
    resultsViewController.view.pin(to: view)
  }
  
  @objc private func dismissViewController() {
    navigationController?.dismiss(animated: true, completion: nil)
  }
  
  private func setupSearchController() {
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.searchBar.showsScopeBar = true
    searchController.isActive = true
    searchController.searchBar.showsCancelButton = false
    searchController.searchBar.scopeButtonTitles = FilterSection.allCases.map(\.title)
    searchController.searchBar.delegate = self
  }
  
}

extension FilterViewController: UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    resultsViewController.setVisibleViewController(atIndex: selectedScope)
  }
  
}

