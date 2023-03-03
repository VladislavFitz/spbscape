//
//  ResultsCountViewModel.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 11.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation

final class ResultsCountViewModel {
  @Published var resultsCount: Int = 0
  @Published var resultsCountTitle: String?

  private var observer: NSObjectProtocol?

  public init(resultsCount: Int) {
    self.resultsCount = resultsCount
    observer = NotificationCenter.default.addObserver(forName: .updateSearchResultsCount,
                                                      object: nil,
                                                      queue: .main) { [weak self] notification in
      guard let resultsCount = notification.userInfo?["searchResultsCount"] as? Int, let self else {
        return
      }
      self.resultsCount = resultsCount
      self.resultsCountTitle = "\("buildings".localize()): \(resultsCount)"
    }
  }

  deinit {
    if let observer {
      NotificationCenter.default.removeObserver(observer)
    }
  }
}
