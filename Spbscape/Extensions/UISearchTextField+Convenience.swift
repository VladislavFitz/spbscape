//
//  UISearchTextField+Convenience.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 18/01/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore

extension UISearchTextField {
    
  func removeTokensForFilter(withAttribute attribute: Attribute) {
    tokens
      .enumerated()
      .filter { ($0.element.representedObject as? FilterType)?.attribute == attribute }
      .map { $0.offset }
      .forEach(removeToken(at:))
  }
  
  func removeTokensForBoundingBox() {
    tokens
      .enumerated()
      .filter { $1.representedObject is BoundingBox }
      .map { $0.0 }
      .forEach(removeToken(at:))
  }
  
}
