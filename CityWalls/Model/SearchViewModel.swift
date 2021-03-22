//
//  SearchViewModel.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 13/03/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import InstantSearch
import UIKit
import CityWallsCore

class SearchViewModel {
  
  let searcher: SingleIndexSearcher
  let queryInputConnector: QueryInputConnector
  let hitsConnector: HitsConnector<Building>
  let filterState: FilterState

  init() {
    filterState = .init()
    searcher = SingleIndexSearcher(appID: .cityWallsAppID, apiKey: .cityWallsApiKey, indexName: .buildings)
    hitsConnector = .init(searcher: searcher, filterState: filterState)
    queryInputConnector = .init(searcher: searcher)

    searcher.connectFilterState(filterState)

    searcher.indexQueryState.query.hitsPerPage = 100
  }
  
  func configure(_ textField: UISearchTextField) {
    textField.placeholder = "Название, адрес, архитектор, стиль..."
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
  
  func hitsCountBarButtonItem() -> UIBarButtonItem {
    let hitsCountBarButtonItem: UIBarButtonItem = .init(title: "Зданий: 0", style: .done, target: nil, action: nil)

    searcher.onResults.subscribePast(with: hitsCountBarButtonItem) { (hitsCountBarButtonItem, response) in
      hitsCountBarButtonItem.title = "Зданий: \(response.searchStats.totalHitsCount)"
    }.onQueue(.main)

    return hitsCountBarButtonItem
    
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