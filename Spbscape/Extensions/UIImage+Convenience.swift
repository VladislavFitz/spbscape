//
//  UIImage+Convenience.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 05.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
  func resizeImageTo(size: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    draw(in: CGRect(origin: CGPoint.zero, size: size))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return resizedImage
  }
}

extension UIImage {
  static var placeholder: UIImage {
    UIImage(systemName: "photo")!
      .resizeImageTo(size: CGSize(width: 138, height: 108))!
      .withTintColor(.lightGray)
  }
}

extension UIImage {
  static func filters(empty: Bool) -> UIImage? {
    let iconName = empty ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill"
    return UIImage(systemName: iconName)
  }
}
