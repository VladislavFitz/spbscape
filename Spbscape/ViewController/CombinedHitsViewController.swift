//
//  CombinedHitsViewController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 14/03/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

final class CombinedHitsViewController: ContainerViewController {
  
  var mode: HitsPresentationMode
  let switchAppearanceModeBarButtonItem: UIBarButtonItem
  
  init(listViewController: UIViewController, mapViewController: UIViewController, initialMode: HitsPresentationMode = .list) {
    mode = initialMode
    switchAppearanceModeBarButtonItem = .init(image: initialMode.nextMode.buttonImage, style: .done, target: nil, action: nil)
    super.init(viewControllers: [listViewController, mapViewController])
    switchAppearanceModeBarButtonItem.target = self
    switchAppearanceModeBarButtonItem.action = #selector(didTogglePresentationMode)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setVisibleViewController(atIndex: mode.controllerIndex)
  }
    
  @objc
  func didTogglePresentationMode(_ barButtonItem: UIBarButtonItem) {
    mode.toggle()
    switchAppearanceModeBarButtonItem.image = mode.nextMode.buttonImage
    setVisibleViewController(atIndex: mode.controllerIndex)
  }
  
}
