//
//  DismissAnimationController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 05.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  var mode: TransitioningDelegate.Mode = .slide

  func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 5
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    // Retrieve the view controllers participating in the current transition from the context.
    let fromView = transitionContext.viewController(forKey: .from)!.view!
    let toView = transitionContext.viewController(forKey: .to)!.view!

    switch mode {
    case .slide:
      UIView.animate(withDuration: 0.5) {
        fromView.frame.origin.x = toView.frame.width
      } completion: { completed in
        transitionContext.completeTransition(completed)
      }
    case .fade:
      UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut]) {
        fromView.alpha = 0
      } completion: { completed in
        transitionContext.completeTransition(completed)
      }
    }
  }
}
