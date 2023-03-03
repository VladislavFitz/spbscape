//
//  OverlayControllerDelegate.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 06.02.2022.
//  Copyright © 2022 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

protocol OverlayControllerDelegate: AnyObject {
  var currentHeight: CGFloat { get }
  var fullscreenOverlayHeight: CGFloat { get }
  var compactOverlayHeight: CGFloat { get }
  var switchStateThreshold: CGFloat { get }

  func didChangeState(_ newState: OverlayStateController.State, animated: Bool)
  func shouldSetHeight(_ height: CGFloat, animated: Bool)
}
