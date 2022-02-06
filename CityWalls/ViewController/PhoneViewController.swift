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
  let searchViewController: SearchViewController
  let overlayController: OverlayController
  
  private var heightConstraint: NSLayoutConstraint!
  private let overlayBottomOffset: CGFloat = 90
  
  init(listViewController: BuldingHitsListViewController, mapViewController: UIViewController) {
    self.listViewController = listViewController
    self.mapViewController = mapViewController
    self.searchViewController = .init(childViewController: listViewController)
    self.overlayController = .init()
    super.init(nibName: nil, bundle: nil)
    for viewController in [mapViewController, searchViewController] {
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
    let overlayView = searchViewController.view!
    overlayView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(overlayView)
    heightConstraint = overlayView.heightAnchor.constraint(equalToConstant: searchViewController.compactHeight)
    activate(
      heightConstraint,
      overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: overlayBottomOffset)
    )
    searchViewController.searchTextField.delegate = self
    overlayController.delegate = self
    overlayController.set(.compact, animated: false)
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let panGestureRecognizer = UIPanGestureRecognizer(target: overlayController, action: #selector(overlayController.didPan(recognizer:)))
    searchViewController.view.addGestureRecognizer(panGestureRecognizer)
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: { _ in
      self.overlayController.set(self.overlayController.state, animated: false)
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
      
}

extension PhoneViewController: OverlayControllerDelegate {
  
  var currentHeight: CGFloat {
    return heightConstraint.constant
  }
  
  var switchStateThreshold: CGFloat {
    return view.bounds.height / 2 + searchViewController.compactHeight
  }
  
  var fullscreenOverlayHeight: CGFloat {
    return view.bounds.height - view.safeAreaInsets.top + overlayBottomOffset
  }
  
  var compactOverlayHeight: CGFloat {
    return searchViewController.compactHeight + overlayBottomOffset
  }

  func shouldSetHeight(_ height: CGFloat, animated: Bool) {
    heightConstraint.constant = height
    guard animated else {
      if searchViewController.searchTextField.isEditing, height < switchStateThreshold {
          searchViewController.searchTextField.endEditing(true)
      }
      return
    }
    let animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut)
    animator.addAnimations {
      self.view.layoutIfNeeded()
    }
    if searchViewController.searchTextField.isEditing, height < switchStateThreshold {
        animator.addCompletion { _ in
            self.searchViewController.searchTextField.endEditing(true)
        }
    }
    animator.startAnimation()
  }
  
  func didChangeState(_ newState: OverlayController.State, animated: Bool) {
    if case .compact = newState {
      if searchViewController.searchTextField.isEditing {
        searchViewController.searchTextField.endEditing(true)
      }
    }
  }
  
}

extension PhoneViewController: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if overlayController.state == .compact {
      overlayController.set(.fullScreen, animated: true)
    }
  }
  
}
