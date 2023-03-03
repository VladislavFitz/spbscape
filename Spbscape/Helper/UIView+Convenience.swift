//
//  UIView+Convenience.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  func activate(_ constraints: NSLayoutConstraint...) {
    NSLayoutConstraint.activate(constraints)
  }

  func pin(to view: UIView, insets: UIEdgeInsets = .zero) {
    activate(
      topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
      bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom),
      leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
      trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: insets.right)
    )
  }

  func pin(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) {
    activate(
      topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: insets.top),
      bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: insets.bottom),
      leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: insets.left),
      trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: insets.right)
    )
  }

  static var placeholder: UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }

  static func placeHolder(width: CGFloat? = nil, height: CGFloat? = nil) -> UIView {
    let placeholder = self.placeholder
    if let width = width {
      placeholder.widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    if let height = height {
      placeholder.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    return placeholder
  }
}
