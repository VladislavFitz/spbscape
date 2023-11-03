//
//  ViewModelFactory.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 03.11.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation

final class ViewModelFactory {

  private let svm: SearchViewModel

  init() {
    self.svm = SearchViewModel()
  }

  func searchViewModel() -> SearchViewModel {
    svm
  }

  func filtersStateViewModel() -> FiltersStateViewModel {
    svm.filtersStateViewModel
  }

  func resultsCountViewModel() -> ResultsCountViewModel {
    svm.resultsCountViewModel
  }

}
