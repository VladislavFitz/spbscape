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
  
  let filterState: FilterState
  let facetValuesQueryInputInteractor: QueryInputInteractor
  let facetValuesSearcher: MultiSearcher
  let facetListConnectors: [FacetListConnector]
  
  var appliedFiltersCount: Int {
    filterState.toFilterGroups().map(\.filters).map(\.count).reduce(0, +)
  }
  
  init(filterState: FilterState) {
    self.filterState = filterState
    facetValuesSearcher = MultiSearcher(appID: .spbscapeAppID, apiKey: .spbscape)
    
    facetListConnectors = FilterSection.allCases.map { [unowned facetValuesSearcher] section in
      let facetSearcher = facetValuesSearcher.addFacetsSearcher(indexName: .buildings,
                                                                attribute: section.attribute)
      let facetListConnector = FacetListConnector(searcher: facetSearcher,
                                                  filterState: filterState,
                                                  attribute: section.attribute,
                                                  operator: .or)
      facetSearcher.connectFilterState(filterState)
      return facetListConnector
    }
    
    facetValuesQueryInputInteractor = QueryInputInteractor()
    facetValuesQueryInputInteractor.connectSearcher(facetValuesSearcher)
    facetValuesQueryInputInteractor.onQueryChanged.fire(nil)
    filterState.onChange.subscribe(with: self) { (viewModel, filterState) in
      let notification = Notification(name: .updateAppliedFiltersCount,
                                      object: self,
                                      userInfo: ["appliedFiltersCount": viewModel.appliedFiltersCount])
      NotificationCenter.default.post(notification)
    }
  }
  
  func setup(_ filterViewController: FiltersViewController) {
    facetValuesQueryInputInteractor.connectController(filterViewController.queryInputController)
    zip(facetListConnectors, filterViewController.viewControllers).forEach { connector, controller in
      connector.connectController(controller)
    }
  }
  
  @objc func resetFilters() {
    (filterState[or: FilterSection.architect.attribute.rawValue] as OrGroupAccessor<Filter.Facet>).removeAll()
    (filterState[or: FilterSection.style.attribute.rawValue] as OrGroupAccessor<Filter.Facet>).removeAll()
    (filterState[or: FilterSection.street.attribute.rawValue] as OrGroupAccessor<Filter.Facet>).removeAll()
    filterState.notifyChange()
  }
  
}
