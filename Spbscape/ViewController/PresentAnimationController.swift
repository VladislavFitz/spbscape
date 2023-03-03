//
//  PresentAnimationController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 05.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  var mode: TransitioningDelegate.Mode = .slide

  func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 5
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    // Retrieve the view controllers participating in the current transition from the context.
    let fromView = transitionContext.viewController(forKey: .from)!.view!
    let toView = transitionContext.viewController(forKey: .to)!.view!

    let presentedWidth = 0.33 * fromView.frame.width

    switch mode {
    case .slide:
      toView.frame = .init(x: fromView.frame.width, y: 0, width: presentedWidth, height: fromView.frame.height)

      UIView.animate(withDuration: 0.5) {
        toView.frame.origin.x = fromView.frame.width - presentedWidth
      } completion: { completed in
        transitionContext.completeTransition(completed)
      }
    case .fade:
      toView.alpha = 0
      toView.frame = .init(x: fromView.frame.width - presentedWidth, y: 0, width: presentedWidth, height: fromView.frame.height)
      UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn]) {
        toView.alpha = 1
      } completion: { completed in
        transitionContext.completeTransition(completed)
      }
    }
  }
}
