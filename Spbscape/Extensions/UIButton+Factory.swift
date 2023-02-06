//
//  UIButton+Factory.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 05.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
  
  static var filter: UIButton {
    let filterButton = UIButton()
    filterButton.translatesAutoresizingMaskIntoConstraints = false
    filterButton.setImage(UIImage(systemName: "line.horizontal.3.decrease.circle"), for: .normal)
    filterButton.contentVerticalAlignment = .fill
    filterButton.contentHorizontalAlignment = .fill
    NSLayoutConstraint.activate([
      filterButton.widthAnchor.constraint(equalToConstant: 28),
      filterButton.heightAnchor.constraint(equalToConstant: 28),
    ])
    return filterButton
  }

}
