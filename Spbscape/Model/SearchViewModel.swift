//
//  SearchViewModel.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 13/03/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import InstantSearch
import UIKit
import SpbscapeCore

class SearchViewModel {
  
  let searcher: HitsSearcher
  let queryInputConnector: QueryInputConnector
  let hitsConnector: HitsConnector<Hit<Building>>
  let filterState: FilterState
  let filtersController: FiltersController

  init() {
    filterState = .init()
    filtersController = .init(filterState: filterState)
    searcher = HitsSearcher(appID: .spbscapeAppID, apiKey: .spbscape, indexName: .buildings)
    hitsConnector = .init(searcher: searcher, filterState: filterState)
    queryInputConnector = .init(searcher: searcher)

    searcher.connectFilterState(filterState)

    searcher.request.query.hitsPerPage = 200
  }
  
  func configure(_ textField: UISearchTextField) {
    textField.placeholder = "searchPlaceholder".localize()
    textField.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
    let queryInputController = TextFieldController(textField: textField)
    queryInputConnector.connectController(queryInputController)
    filterState.onChange.subscribe(with: self) { controller, container in
      textField.tokens.removeAll()
      container
        .toFilterGroups()
        .flatMap(\.filters)
        .compactMap(UISearchToken.init)
        .forEach { textField.insertToken($0, at: 0) }
    }
  }
  
  @objc func didChangeText(_ textField: UISearchTextField) {
    let filtersFromTokens = Set(textField.tokens.compactMap { $0.representedObject as? Filter.Facet })
    filterState
      .toFilterGroups()
      .flatMap(\.filters)
      .compactMap { $0 as? Filter.Facet }
      .filter { !filtersFromTokens.contains($0) }
      .forEach { filterState.remove($0) }
    filterState.notifyChange()
  }
  
  func hitsCountBarButtonItem() -> UIBarButtonItem {
    let barButtonItem = ResultsCountBarButtonItem()
    barButtonItem.setResultsCount(0)
    searcher.onResults.subscribePast(with: barButtonItem) { (barButtonItem, response) in
      barButtonItem.setResultsCount(response.searchStats.totalHitsCount)
    }.onQueue(.main)
    
    barButtonItem.cancelSubscription = { [weak self] in
      self?.searcher.onResults.cancelSubscription(for: barButtonItem)
    }
    return barButtonItem
  }
  
  func filtersBarButtonItem() -> UIBarButtonItem {
    let barButtonItem = FiltersBarButtonItem()
    barButtonItem.setFiltersEmpty(true)
    filterState.onChange.subscribePast(with: barButtonItem) { (item, filterState) in
      let areFiltersEmpty = filterState.toFilterGroups().map(\.filters).allSatisfy(\.isEmpty)
      barButtonItem.setFiltersEmpty(areFiltersEmpty)
    }.onQueue(.main)
    
    barButtonItem.cancelSubscription = { [weak self] in
      self?.filterState.onChange.cancelSubscription(for: barButtonItem)
    }
    
    return barButtonItem
  }
  
  func clearFiltersBarButtonItem() -> UIBarButtonItem {
    let clearFiltersBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash.circle"),
                                                    style: .done,
                                                    target: self,
                                                    action: #selector(resetFilters))
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
    return clearFiltersBarButtonItem
  }
  
  func filtersButton() -> UIButton {
    let button = FiltersButton()
    button.setFiltersEmpty(true)
    filterState.onChange.subscribePast(with: button) { (button, filterState) in
      let areFiltersEmpty = filterState.toFilterGroups().map(\.filters).allSatisfy(\.isEmpty)
      button.setFiltersEmpty(areFiltersEmpty)
    }.onQueue(.main)
    button.cancelSubscription = { [weak self] in
      self?.filterState.onChange.cancelSubscription(for: button)
    }
    return button
  }
  
  @objc private func resetFilters() {
    (filterState[or: FilterSection.architect.attribute.rawValue] as OrGroupAccessor<Filter.Facet>).removeAll()
    (filterState[or: FilterSection.style.attribute.rawValue] as OrGroupAccessor<Filter.Facet>).removeAll()
    (filterState[or: FilterSection.street.attribute.rawValue] as OrGroupAccessor<Filter.Facet>).removeAll()
    filterState.notifyChange()
  }
  
}
