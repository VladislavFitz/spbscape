//
//  TransitioningDelegate.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 05.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
  enum Mode {
    case fade
    case slide
  }

  let presentController: PresentAnimationController
  let dismissController: DismissAnimationController

  init(presentController: PresentAnimationController = .init(), dismissController: DismissAnimationController = .init()) {
    self.presentController = presentController
    self.dismissController = dismissController
  }

  func animationController(forPresented _: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return presentController
  }

  func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return dismissController
  }

  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source _: UIViewController) -> UIPresentationController? {
    return SidebarOverlayPresentationController(presentedViewController: presented, presenting: presenting)
  }
}
