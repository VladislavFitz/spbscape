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
  let queryInputController: TextFieldController
  let hitsConnector: HitsConnector<Building>
  let filterState: FilterState

  init(textField: UISearchTextField) {
    filterState = .init()
    searcher = SingleIndexSearcher(appID: .cityWallsAppID, apiKey: .cityWallsApiKey, indexName: .buildings)
    hitsConnector = .init(searcher: searcher, filterState: filterState)
    queryInputController = .init(textField: textField)
    queryInputConnector = .init(searcher: searcher, controller: queryInputController)

    searcher.connectFilterState(filterState)
    filterState.onChange.subscribe(with: self) { controller, container in
      textField.tokens.removeAll()
      container
        .toFilterGroups()
        .flatMap(\.filters)
        .compactMap(UISearchToken.init)
        .forEach { textField.insertToken($0, at: 0) }
    }
  }
  
}
