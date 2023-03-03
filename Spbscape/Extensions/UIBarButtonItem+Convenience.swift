//
//  UIBarButtonItem+Convenience.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 11.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {
  static var flexibleSpace: UIBarButtonItem {
    UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                    target: nil,
                    action: nil)
  }
}
