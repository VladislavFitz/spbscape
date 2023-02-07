//
//  FiltersButton.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 07.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

final class FiltersButton: UIButton {
  
  var cancelSubscription: () -> Void = {}
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentVerticalAlignment = .fill
    contentHorizontalAlignment = .fill
    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: 28),
      heightAnchor.constraint(equalToConstant: 28),
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setFiltersEmpty(_ areFiltersEmpty: Bool) {
    setImage(.filters(empty: areFiltersEmpty), for: .normal)
  }
  
  deinit {
    cancelSubscription()
  }
  
}
