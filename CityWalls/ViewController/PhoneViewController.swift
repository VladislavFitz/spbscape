//
//  PhoneViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 05.02.2022.
//  Copyright © 2022 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class PhoneViewController: UIViewController {
  
  let listViewController: BuldingHitsListViewController
  let mapViewController: UIViewController
  let overlayViewController: SearchOverlayViewController
  var heightConstraint: NSLayoutConstraint!
  
  init(listViewController: BuldingHitsListViewController, mapViewController: UIViewController) {
    self.listViewController = listViewController
    self.mapViewController = mapViewController
    self.overlayViewController = .init(childViewController: listViewController)
    super.init(nibName: nil, bundle: nil)
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
    heightConstraint = overlayView.heightAnchor.constraint(equalToConstant: overlayViewController.compactHeight)
    activate(
      heightConstraint,
      overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomOffset)
    )
    overlayViewController.searchTextField.delegate = self
    state = .compact
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(recognizer:)))
    overlayViewController.view.addGestureRecognizer(panGestureRecognizer)
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: { _ in
      self.set(self.state, animated: false)
    }, completion: nil)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    set(state, animated: true)
  }
  
  private var initialHeight: CGFloat = 0
  
  var threshold: CGFloat {
    return view.bounds.height / 2 + overlayViewController.compactHeight
  }
  
  @objc func didPan(recognizer: UIPanGestureRecognizer) {
    switch recognizer.state {
    case .began:
      initialHeight = heightConstraint.constant

    case .changed:
      let translationY = recognizer.translation(in: recognizer.view).y
      let newHeight = initialHeight - translationY
      set(.custom(newHeight), animated: false)

    case .ended:
      if heightConstraint.constant > threshold {
        set(.fullScreen, animated: true)
      } else {
        set(.compact, animated: true)
      }
    case .cancelled, .failed:
      break

    default:
      break
    }
  }
  
  enum OverlayState: Equatable {
    case fullScreen
    case compact
    case custom(CGFloat)
  }
  
  let bottomOffset: CGFloat = 90
  
  var fullscreenOverlayHeight: CGFloat {
    return view.bounds.height - view.safeAreaInsets.top + bottomOffset
  }
  
  var compactOverlayHeight: CGFloat {
    return overlayViewController.compactHeight + bottomOffset
  }
  
  var state: OverlayState = .compact {
    didSet {
      heightConstraint.constant = overlayHeight(for: state)
    }
  }
  
  func overlayHeight(for state: OverlayState) -> CGFloat {
    switch state {
    case .fullScreen:
      return fullscreenOverlayHeight
    case .compact:
      return compactOverlayHeight
    case .custom(let height):
      return height
    }
  }

  func set(_ state: OverlayState, animated: Bool) {
    self.state = state
    guard animated else {
      if case .custom(let height) = state, height < threshold, overlayViewController.searchTextField.isEditing {
        overlayViewController.searchTextField.endEditing(true)
      } else if state == .compact, overlayViewController.searchTextField.isEditing {
        overlayViewController.searchTextField.endEditing(true)
      }
      return
    }
    let animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut)
    animator.addAnimations {
      self.view.layoutIfNeeded()
    }
    if state == .compact, overlayViewController.searchTextField.isEditing {
      animator.addCompletion { _ in
          self.overlayViewController.searchTextField.endEditing(true)
      }
    }
    animator.startAnimation()
  }
  
}

extension PhoneViewController: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if state == .compact {
      set(.fullScreen, animated: true)
    }
  }
  
}
