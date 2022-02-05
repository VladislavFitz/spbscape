//
//  PhoneViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 05.02.2022.
//  Copyright © 2022 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class PhoneViewController: UIViewController, OverlayStateProvider {
  
  let listViewController: BuldingHitsListViewController
  let mapViewController: UIViewController
  let overlayViewController: SearchOverlayViewController
  var transitionCoordiantor: TransitionCoordinator!
  var constraint: NSLayoutConstraint!
  
  init(listViewController: BuldingHitsListViewController, mapViewController: UIViewController) {
    self.listViewController = listViewController
    self.mapViewController = mapViewController
    self.overlayViewController = .init(childViewController: listViewController)
    super.init(nibName: nil, bundle: nil)
    transitionCoordiantor = TransitionCoordinator(stateProvider: self)
    for viewController in [mapViewController, overlayViewController] {
      addChild(viewController)
      viewController.didMove(toParent: self)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let mapView = mapViewController.view!
    mapView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(mapView)
    activate(
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    )
    let overlayView = overlayViewController.view!
    overlayView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(overlayView)
    constraint = overlayView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: state.offset)
    constraint.isActive = true
    activate(
      overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      overlayView.heightAnchor.constraint(equalToConstant: 770)
    )
    overlayViewController.searchTextField.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let panGestureRecognizer = UIPanGestureRecognizer(target: transitionCoordiantor, action: #selector(transitionCoordiantor.didPan(recognizer:)))
    overlayViewController.view.addGestureRecognizer(panGestureRecognizer)
  }
  
  enum OverlayState: Equatable {
    
    case fullScreen
    case bottom
    case custom(CGFloat)
    
    var offset: CGFloat {
      switch self {
      case .fullScreen:
        return -720
      case .bottom:
        return -84
      case .custom(let offset):
        return offset
      }
    }
    
    static let threshold: CGFloat = -450
    
  }
  
  var state: OverlayState = .bottom {
    didSet {
      constraint.constant = state.offset
    }
  }
  
  func set(_ state: OverlayState, animated: Bool) {
    self.state = state
    guard animated else {
      if state == .bottom, overlayViewController.searchTextField.isEditing {
        overlayViewController.searchTextField.endEditing(true)
      }
      return
    }
    let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut)
    animator.addAnimations {
      self.view.layoutIfNeeded()
    }
    if state == .bottom {
      animator.addCompletion { _ in
        if self.overlayViewController.searchTextField.isEditing {
          self.overlayViewController.searchTextField.endEditing(true)
        }
      }
    }
    animator.startAnimation()
  }
  
}

extension PhoneViewController: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if state == .bottom {
      set(.fullScreen, animated: true)
    }
  }
  
}

protocol OverlayStateProvider {
  
  var state: PhoneViewController.OverlayState { get set }
  
  func set(_ state: PhoneViewController.OverlayState, animated: Bool)

}

class TransitionCoordinator: NSObject {
  
  var stateProvider: OverlayStateProvider
  private var initialPosition: CGFloat = 0

  init(stateProvider: OverlayStateProvider) {
    self.stateProvider = stateProvider
  }
    
  @objc func didPan(recognizer: UIPanGestureRecognizer) {
    switch recognizer.state {
    case .began:
      initialPosition = stateProvider.state.offset

    case .changed:
      let translationY = recognizer.translation(in: recognizer.view).y
      let newPosition = initialPosition + translationY
      stateProvider.state = .custom(newPosition)

    case .ended:
      if stateProvider.state.offset < PhoneViewController.OverlayState.threshold {
        stateProvider.set(.fullScreen, animated: true)
      } else {
        stateProvider.set(.bottom, animated: true)
      }
    case .cancelled, .failed:
      break

    default:
      break
    }
  }
  
}
