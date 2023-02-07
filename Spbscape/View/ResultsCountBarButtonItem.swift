//
//  ResultsCountBarButtonItem.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 07.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

final class ResultsCountBarButtonItem: UIBarButtonItem {
  
  var cancelSubscription: () -> Void = {}
  
  func setResultsCount(_ resultsCount: Int) {
    title = "\("buildings".localize()): \(resultsCount)"
  }
    
  deinit {
    cancelSubscription()
  }
    
}
