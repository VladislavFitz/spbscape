//
//  BlurryPanel.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 06.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class BlurryPanel: UIView {
  
  let blurBackgroundView: UIVisualEffectView
  let stackView: UIStackView
  
  override init(frame: CGRect) {
    blurBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    stackView = UIStackView()
    super.init(frame: frame)
    
    blurBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    blurBackgroundView.layer.cornerRadius = 12
    blurBackgroundView.layer.masksToBounds = true
    addSubview(blurBackgroundView)
    blurBackgroundView.pin(to: self)

    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.alignment = .center
    blurBackgroundView.contentView.addSubview(stackView)
    stackView.pin(to: blurBackgroundView,
                  insets: UIEdgeInsets(top: 8,
                                       left: 15,
                                       bottom: -8,
                                       right: -15))
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
