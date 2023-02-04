//
//  ToolbarContainer.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 18/01/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class ToolbarContainer: UIView {
  
  let toolbar: UIToolbar
  
  init(toolbar: UIToolbar) {
    self.toolbar = toolbar
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup() {
    translatesAutoresizingMaskIntoConstraints = false
    
    let backgroundView = UIView()
    backgroundView.backgroundColor = .systemBackground
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(backgroundView)
    backgroundView.pin(to: self)
    
    toolbar.translatesAutoresizingMaskIntoConstraints = false
    addSubview(toolbar)
    NSLayoutConstraint.activate([
      toolbar.heightAnchor.constraint(equalToConstant: 44),
      toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
      toolbar.trailingAnchor.constraint(equalTo: trailingAnchor),
      toolbar.topAnchor.constraint(equalTo: topAnchor),
      toolbar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
    ])
  }
  
  override var intrinsicContentSize: CGSize {
    return .init(width: UIScreen.main.bounds.width, height: 44)
  }
  
}
