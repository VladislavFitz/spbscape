//
//  OverlayStateController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 06.02.2022.
//  Copyright © 2022 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class OverlayStateController: NSObject {
  
  weak var delegate: OverlayControllerDelegate?
  
  enum State: Equatable {
    case fullScreen
    case compact
  }
  
  private(set) var state: State = .compact {
    didSet {
      guard let delegate = delegate else {
        return
      }
      delegate.didChangeState(state, animated: false)
    }
  }
  
  func overlayHeight(for state: State) -> CGFloat {
    switch state {
    case .fullScreen:
      return delegate?.fullscreenOverlayHeight ?? 0
    case .compact:
      return delegate?.compactOverlayHeight ?? 0
    }
  }
  
  func set(_ state: State, animated: Bool) {
    self.state = state
    guard let delegate = delegate else {
      return
    }
    delegate.shouldSetHeight(overlayHeight(for: state), animated: animated)
  }
  
  private var initialHeight: CGFloat = 0

  @objc public func didPan(recognizer: UIPanGestureRecognizer) {
    guard let delegate = delegate else {
      return
    }
    
    switch recognizer.state {
    case .began:
      initialHeight = delegate.currentHeight

    case .changed:
      let translationY = recognizer.translation(in: recognizer.view).y
      delegate.shouldSetHeight(initialHeight - translationY, animated: false)

    case .ended, .cancelled, .failed:
      let endState: State
      if delegate.currentHeight > delegate.switchStateThreshold {
        endState = .fullScreen
      } else {
        endState = .compact
      }
      delegate.shouldSetHeight(overlayHeight(for: endState), animated: true)
      state = endState

    default:
      break
    }
  }

}
