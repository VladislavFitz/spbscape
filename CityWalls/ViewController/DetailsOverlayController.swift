//
//  DetailsOverlayController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 28/03/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class DetailsOverlayController: UIViewController {
  
  let viewController: UIViewController
  
  init(viewController: UIViewController) {
    self.viewController = viewController
    super.init(nibName: nil, bundle: nil)
    addChild(viewController)
    viewController.willMove(toParent: self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let contentView = viewController.view else { return }
    
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    
    view.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    activate(
      contentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
      contentView.topAnchor.constraint(equalTo: view.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    )
  }
  
  @objc func didTap() {
    dismiss(animated: true, completion: nil)
  }
  
}
