//
//  OverlayingView.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 12.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation

protocol OverlayingView {
  
  var compactHeight: CGFloat { get }
  
  func notifyCompact()
  
}
