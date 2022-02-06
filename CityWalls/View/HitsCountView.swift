//
//  HitsCountView.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 06.02.2022.
//  Copyright © 2022 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class HitsCountView: UIView {
  
  let countLabel: UILabel
  
  override init(frame: CGRect) {
    self.countLabel = .init()
    super.init(frame: frame)
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayout() {
    countLabel.textColor = ColorScheme.tintColor
    countLabel.textAlignment = .center
    countLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(countLabel)
    activate(
      countLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -5),
      countLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
      countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
    )
  }
  
}
