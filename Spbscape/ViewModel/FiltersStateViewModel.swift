//
//  FiltersStateViewModel.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 11.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

final class FiltersStateViewModel {
  
  var areFiltersEmpty: Bool {
    didSet {
      for (id, observation) in observations {
        guard let observer = observation.observer else {
          observations.removeValue(forKey: id)
          continue
        }
        observer.setFiltersEmpty(areFiltersEmpty)
      }
    }
  }
  
  private var _clearFilters: () -> Void
  private var observer: NSObjectProtocol?
  private var observations: [ObjectIdentifier: Observation]
  
  init(areFiltersEmpty: Bool, clearFilters: @escaping () -> Void) {
    self._clearFilters = clearFilters
    self.areFiltersEmpty = areFiltersEmpty
    self.observations = [:]
    observer = NotificationCenter.default.addObserver(forName: .updateAppliedFiltersCount,
                                                      object: nil,
                                                      queue: .main) { [weak self] notification in
      guard let appliedFiltersCount = notification.userInfo?["appliedFiltersCount"] as? Int, let self else {
        return
      }
      self.areFiltersEmpty = appliedFiltersCount == 0
    }
  }
  
  public func addObserver(_ observer: FiltersStateObserver) {
    let id = ObjectIdentifier(observer)
    observations[id] = Observation(observer: observer)
  }
  
  func removeObserver(_ observer: FiltersStateObserver) {
    let id = ObjectIdentifier(observer)
    observations.removeValue(forKey: id)
  }
  
  func filtersButtonImage() -> UIImage {
    let iconName = areFiltersEmpty ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill"
    return UIImage(systemName: iconName)!
  }
  
  func clearFilters() {
    _clearFilters()
  }
  
}

private extension FiltersStateViewModel {
  
  struct Observation {
    weak var observer: FiltersStateObserver?
  }
  
}

protocol FiltersStateObserver: AnyObject {
  
  func setFiltersEmpty(_ empty: Bool)
  
}
