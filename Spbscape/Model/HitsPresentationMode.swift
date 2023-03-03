//
//  HitsPresentationMode.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 14/03/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

enum HitsPresentationMode {
  case list
  case map

  var nextMode: HitsPresentationMode {
    switch self {
    case .list:
      return .map
    case .map:
      return .list
    }
  }

  var buttonImage: UIImage? {
    let symbolName: String
    switch self {
    case .list:
      symbolName = "list.dash"
    case .map:
      symbolName = "map"
    }
    return UIImage(systemName: symbolName)
  }

  var controllerIndex: Int {
    switch self {
    case .list:
      return 0
    case .map:
      return 1
    }
  }

  mutating func toggle() {
    self = (self == .list) ? .map : .list
  }
}
