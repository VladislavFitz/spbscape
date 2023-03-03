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
  private var _clearFilters: () -> Void

  @Published var areFiltersEmpty: Bool = true
  @Published var filtersButtonImage: UIImage? = UIImage(systemName: "line.horizontal.3.decrease.circle")
  private var observer: NSObjectProtocol?

  init(areFiltersEmpty: Bool, clearFilters: @escaping () -> Void) {
    _clearFilters = clearFilters
    self.areFiltersEmpty = areFiltersEmpty
    observer = NotificationCenter.default.addObserver(forName: .updateAppliedFiltersCount,
                                                      object: nil,
                                                      queue: .main) { [weak self] notification in
      guard let appliedFiltersCount = notification.userInfo?["appliedFiltersCount"] as? Int, let self else {
        return
      }
      self.areFiltersEmpty = appliedFiltersCount == 0
      let iconName: String
      if appliedFiltersCount == 0 {
        iconName = "line.horizontal.3.decrease.circle"
      } else {
        iconName = "line.horizontal.3.decrease.circle.fill"
      }
      self.filtersButtonImage = UIImage(systemName: iconName)
    }
  }

  func clearFilters() {
    _clearFilters()
  }
}
