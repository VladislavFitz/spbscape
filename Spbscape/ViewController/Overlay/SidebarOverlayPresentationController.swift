//
//  SidebarOverlayPresentationController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 05.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class SidebarOverlayPresentationController: UIPresentationController {
  
  override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(pan:)))
    presentedViewController.view.addGestureRecognizer(panGesture)
  }
  
  @objc func didPan(pan: UIPanGestureRecognizer) {
      guard let presented = presentedView,
            let container = containerView else { return }
      
    let location = pan.translation(in: presentingViewController.view)
    
      switch pan.state {
      case .changed where location.x > 0 :// where location.x > 0 && presented.frame.origin.x >= presentingViewController.view.frame.width * 0.66:
        presented.frame.origin.x = /*container.frame.origin.x +*/ location.x

      case .ended:
        let maxPresentedX = container.frame.width * 0.5/*0.66 + container.frame.width / 6*/
          switch presented.frame.origin.x {
          case 0...maxPresentedX:
            restore()
          default:
            presentedViewController.dismiss(animated: true, completion: nil)
          }
      default:
          break
      }
  }
  
  @objc func didTap(tap: UITapGestureRecognizer) {
    guard let containerView = containerView else { return }
    guard tap.location(in: containerView).x < containerView.frame.width * 2 / 3 else { return }
    presentedViewController.dismiss(animated: true, completion: nil)
  }
  
  func restore() {
    guard let presented = presentedView else { return }
    UIView.animate(withDuration: 0.5) {
      presented.frame = self.frameOfPresentedViewInContainerView
    } completion: { _ in
      
    }
  }
  
  override var frameOfPresentedViewInContainerView: CGRect {
    guard let container = containerView else { return .zero }
    return CGRect(x: /*container.bounds.width * 2 / 3*/0, y: 0, width: container.bounds.width  / 3, height: container.bounds.height)
  }
  
  override func presentationTransitionWillBegin() {
    guard let container = containerView else { return }
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(tap:)))
    container.addGestureRecognizer(tapGestureRecognizer)
    
    presentedViewController.view.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(presentedViewController.view)
    NSLayoutConstraint.activate([
      presentedViewController.view.topAnchor.constraint(equalTo: container.topAnchor),
      presentedViewController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      presentedViewController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      presentedViewController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
    ])

    container.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      container.widthAnchor.constraint(equalTo: presentingViewController.view.widthAnchor, multiplier: 0.3),
      container.topAnchor.constraint(equalTo: presentingViewController.view.topAnchor),
      container.bottomAnchor.constraint(equalTo: presentingViewController.view.bottomAnchor),
      container.trailingAnchor.constraint(equalTo: presentingViewController.view.trailingAnchor),
    ])
  }
  
  
  override func dismissalTransitionWillBegin() {
  }
  
  override func dismissalTransitionDidEnd(_ completed: Bool) {
      if completed {
        presentedViewController.view.removeFromSuperview()
      }
  }
  
}
