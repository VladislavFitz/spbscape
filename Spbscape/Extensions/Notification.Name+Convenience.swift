//
//  Notification.Name+Convenience.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 11.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation

extension Notification.Name {
  static let updateAppliedFiltersCount = Self(rawValue: "updateAppliedFiltersCount")
  static let updateSearchResultsCount = Self(rawValue: "updateSearchResultsCount")
}

extension Notification.Name {
  static let showFilters = Self(rawValue: "com.spbscape.filters")
}
