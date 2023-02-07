//
//  FiltersViewModel.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 17/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearch

final class FiltersViewModel {
  
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
  
  func setup(_ filterViewController: FiltersViewController) {
    setupClearFiltersBarButtonItem(filterViewController.clearFiltersBarButtonItem)
    queryInputInteractor.connectController(filterViewController.queryInputController)
    zip(facetListConnectors, filterViewController.viewControllers).forEach { connector, controller in
      connector.connectController(controller)
    }
    filterViewController.clearFilters = { [weak self] in
      self?.resetFilters()
    }
  }
  
  func setupFiltersButton(_ filtersButton: FiltersButton) {
    filtersButton.setFiltersEmpty(true)
    filterState.onChange.subscribePast(with: filtersButton) { (button, filterState) in
      let areFiltersEmpty = filterState.toFilterGroups().map(\.filters).allSatisfy(\.isEmpty)
      filtersButton.setFiltersEmpty(areFiltersEmpty)
    }.onQueue(.main)
  }
  
  private func setupClearFiltersBarButtonItem(_ clearFiltersBarButtonItem: UIBarButtonItem) {
    let hasAppliedFilter = !FilterSection.allCases
      .map(\.attribute.rawValue)
      .map { filterState[or: $0] as OrGroupAccessor<Filter.Facet> }
      .map(\.isEmpty)
      .allSatisfy { $0 }
    clearFiltersBarButtonItem.isEnabled = hasAppliedFilter
    filterState.onChange.subscribePast(with: self) { (vc, filters) in
      let hasAppliedFilter = !FilterSection.allCases
        .map(\.attribute.rawValue)
        .map { vc.filterState[or: $0] as OrGroupAccessor<Filter.Facet> }
        .map(\.isEmpty)
        .allSatisfy { $0 }
      clearFiltersBarButtonItem.isEnabled = hasAppliedFilter
    }.onQueue(.main)
  }
  
  @objc func resetFilters() {
    (filterState[or: FilterSection.architect.attribute.rawValue] as OrGroupAccessor<Filter.Facet>).removeAll()
    (filterState[or: FilterSection.style.attribute.rawValue] as OrGroupAccessor<Filter.Facet>).removeAll()
    (filterState[or: FilterSection.street.attribute.rawValue] as OrGroupAccessor<Filter.Facet>).removeAll()
    filterState.notifyChange()
  }
  
}
