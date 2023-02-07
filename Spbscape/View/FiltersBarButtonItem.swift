//
//  FiltersBarButtonItem.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 07.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

final class FiltersBarButtonItem: UIBarButtonItem {
  
  var cancelSubscription: () -> Void = {}
  
  func setFiltersEmpty(_ areFiltersEmpty: Bool) {
    image = .filters(empty: areFiltersEmpty)
  }
  
  deinit {
    cancelSubscription()
  }
  
}
