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
  let filtersViewModel: FiltersViewModel

  init() {
    filterState = .init()
    filtersViewModel = .init(filterState: filterState)
    searcher = HitsSearcher(appID: .spbscapeAppID, apiKey: .spbscape, indexName: .buildings)
    hitsConnector = .init(searcher: searcher, filterState: filterState)
    queryInputConnector = .init(searcher: searcher)
    searcher.connectFilterState(filterState)
    searcher.request.query.hitsPerPage = 200
  }
  
  func setup(_ searchViewController: SearchViewController) {
    setup(searchViewController.searchTextField)
    setupResultsCountView(searchViewController.hitsCountView)
    filtersViewModel.setupFiltersButton(searchViewController.filterButton)
    searcher.search()
  }
  
  func setup(_ filtersViewController: FiltersViewController) {
    if let resultsCountItem = filtersViewController.resultsCountBarButtonItem {
      setupResultsCountBarButtonItem(resultsCountItem)
    }
    filtersViewModel.setup(filtersViewController)
  }
  
  private static func resultsCountTitle(count: Int) -> String {
    "\("buildings".localize()): \(count)"
  }
  
  private func setupResultsCountBarButtonItem(_ barButtonItem: UIBarButtonItem) {
    barButtonItem.title = SearchViewModel.resultsCountTitle(count: 0)
    searcher.onResults.subscribePast(with: barButtonItem) { (barButtonItem, response) in
      let hitsCount = response.searchStats.totalHitsCount
      barButtonItem.title = SearchViewModel.resultsCountTitle(count: hitsCount)
    }.onQueue(.main)
  }
  
  private func setupResultsCountView(_ hitsCountView: HitsCountView) {
    hitsCountView.countLabel.text = SearchViewModel.resultsCountTitle(count: 0)
    searcher.onResults.subscribePast(with: hitsCountView) { (view, response) in
      let hitsCount = response.searchStats.totalHitsCount
      view.countLabel.text = SearchViewModel.resultsCountTitle(count: hitsCount)
    }.onQueue(.main)
  }
  
  private func setup(_ textField: UISearchTextField) {
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

}
