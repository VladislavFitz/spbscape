//
//  HandleView.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 06.02.2022.
//  Copyright © 2022 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class HandleView: UIView {
  let handleBar: UIVisualEffectView

  var visualEffect: UIVisualEffect {
    switch traitCollection.userInterfaceStyle {
    case .dark:
      return UIBlurEffect(style: .systemThinMaterialLight)
    default:
      return UIBlurEffect(style: .systemThinMaterialDark)
    }
  }

  override init(frame: CGRect) {
    handleBar = UIVisualEffectView(autolayout: ())
    super.init(frame: frame)
    handleBar.effect = visualEffect
    setupLayout()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    handleBar.effect = visualEffect
  }

  private func setupLayout() {
    addSubview(handleBar)
    handleBar.clipsToBounds = true
    handleBar.layer.cornerRadius = 2
    activate(
      handleBar.heightAnchor.constraint(equalToConstant: 4),
      handleBar.widthAnchor.constraint(equalToConstant: 40),
      handleBar.centerXAnchor.constraint(equalTo: centerXAnchor),
      handleBar.centerYAnchor.constraint(equalTo: centerYAnchor)
    )
  }
}
