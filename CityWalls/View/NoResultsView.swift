//
//  NoResultsView.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 04.01.2022.
//  Copyright © 2022 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class NoResultsView: UIView {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Нет результатов"
    label.textAlignment = .center
    addSubview(label)
    activate(
      label.centerXAnchor.constraint(equalTo: centerXAnchor),
      label.centerYAnchor.constraint(equalTo: centerYAnchor)
    )
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
