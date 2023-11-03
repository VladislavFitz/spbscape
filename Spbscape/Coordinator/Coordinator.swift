//
//  Coordinator.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 03.11.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import SpbscapeCore

protocol Coordinator {

  func rootViewController() -> UIViewController
  func presentRoot()
  func presentBuilding(_ building: Building)
}
