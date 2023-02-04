//
//  FilterSection.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 12/12/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import AlgoliaSearchClient

enum FilterSection: Int, CaseIterable {
  case street
  case architect
  case style
  
  var title: String {
    switch self {
    case .street:
      return "streets".localize()
    case .architect:
      return "architects".localize()
    case .style:
      return "styles".localize()
    }
  }
  
  var attribute: Attribute {
    switch self {
    case .street:
      return "addresses.streetName"
    case .architect:
      return "architects.title"
    case .style:
      return "styles.title"
    }
  }
  
}
