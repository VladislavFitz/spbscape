//
//  ResultsCountViewModel.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 11.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation

final class ResultsCountViewModel {
  
  private var resultsCount: Int {
    didSet {
      for (id, observation) in observations {
        guard let observer = observation.observer else {
          observations.removeValue(forKey: id)
          continue
        }
        observer.setResultsCount(resultsCountTitle())
      }
    }
  }
  
  private var observer: NSObjectProtocol?
  private var observations: [ObjectIdentifier : Observation]
  
  public init(resultsCount: Int) {
    self.resultsCount = resultsCount
    self.observations = [:]
    observer = NotificationCenter.default.addObserver(forName: .updateSearchResultsCount,
                                                      object: nil,
                                                      queue: .main) { [weak self] notification in
      guard let resultsCount = notification.userInfo?["searchResultsCount"] as? Int, let self else {
        return
      }
      self.resultsCount = resultsCount
    }
  }
  
  public func resultsCountTitle() -> String {
    "\("buildings".localize()): \(resultsCount)"
  }
  
  public func addObserver(_ observer: ResultsCountObserver) {
    let id = ObjectIdentifier(observer)
    observations[id] = Observation(observer: observer)
  }
  
  func removeObserver(_ observer: ResultsCountObserver) {
    let id = ObjectIdentifier(observer)
    observations.removeValue(forKey: id)
  }
  
  deinit {
    if let observer {
      NotificationCenter.default.removeObserver(observer)
    }
  }
  
}

private extension ResultsCountViewModel {
  
  struct Observation {
    weak var observer: ResultsCountObserver?
  }
  
}

protocol ResultsCountObserver: AnyObject {
  func setResultsCount(_ resultsCount: String)
}
