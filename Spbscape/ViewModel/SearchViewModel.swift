//
//  SearchViewModel.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 13/03/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import InstantSearch
import SpbscapeCore
import UIKit

class SearchViewModel {
  let searcher: HitsSearcher
  let queryInputConnector: QueryInputConnector
  let hitsConnector: HitsConnector<Hit<Building>>
  let filterState: FilterState
  let filtersViewModel: FiltersViewModel
  let resultsCountViewModel: ResultsCountViewModel
  let filtersStateViewModel: FiltersStateViewModel

  init() {
    filterState = FilterState()
    filtersViewModel = FiltersViewModel(filterState: filterState)
    searcher = HitsSearcher(appID: .spbscapeAppID, apiKey: .spbscape, indexName: .buildings)
    hitsConnector = HitsConnector(searcher: searcher, filterState: filterState)
    queryInputConnector = QueryInputConnector(searcher: searcher)
    resultsCountViewModel = ResultsCountViewModel(resultsCount: 0)
    filtersStateViewModel = FiltersStateViewModel(areFiltersEmpty: true,
                                                  clearFilters: filtersViewModel.resetFilters)
    searcher.connectFilterState(filterState)
    searcher.request.query.hitsPerPage = 200
    searcher.onResults.subscribePast(with: self) { _, response in
      let searchResultsCount = response.searchStats.totalHitsCount
      let notification = Notification(name: .updateSearchResultsCount,
                                      object: self,
                                      userInfo: ["searchResultsCount": searchResultsCount])
      NotificationCenter.default.post(notification)
    }.onQueue(.main)
  }

  func setup(_ searchViewController: SearchViewController) {
    setup(searchViewController.headerViewController.searchTextField)
  }

  func setup(_ filtersViewController: FiltersViewController) {
    filtersViewModel.setup(filtersViewController)
  }

  private func setup(_ textField: UISearchTextField) {
    textField.placeholder = "searchPlaceholder".localize()
    textField.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
    let queryInputController = TextFieldController(textField: textField)
    queryInputConnector.connectController(queryInputController)
    filterState.onChange.subscribe(with: self) { _, container in
      textField.tokens.removeAll()
      container
        .toFilterGroups()
        .flatMap(\.filters)
        .compactMap(UISearchToken.init)
        .forEach { textField.insertToken($0, at: 0) }
    }
  }

  @objc private func didChangeText(_ textField: UISearchTextField) {
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
