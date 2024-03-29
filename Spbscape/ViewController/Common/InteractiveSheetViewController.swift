//
//  InteractiveSheetViewController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 05.02.2022.
//  Copyright © 2022 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class InteractiveSheetViewController: UIViewController {
  let mainViewController: UIViewController
  let overlayViewController: UIViewController & OverlayingView

  private let overlayStateController: OverlayStateController
  private var heightConstraint: NSLayoutConstraint!
  private let overlayBottomOffset: CGFloat = 90

  init(mainViewController: UIViewController,
       overlayViewController: UIViewController & OverlayingView) {
    self.mainViewController = mainViewController
    self.overlayViewController = overlayViewController
    overlayStateController = OverlayStateController()
    super.init(nibName: nil, bundle: nil)
    for viewController in [mainViewController, overlayViewController] {
      addChild(viewController)
      viewController.didMove(toParent: self)
    }
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupMainView()
    setupOverlayView()
    overlayStateController.delegate = self
    overlayStateController.set(.compact, animated: false)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let panGestureRecognizer = UIPanGestureRecognizer(target: overlayStateController,
                                                      action: #selector(overlayStateController.didPan(recognizer:)))
    overlayViewController.view.addGestureRecognizer(panGestureRecognizer)
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: { _ in
      self.overlayStateController.set(self.overlayStateController.state, animated: false)
      self.view.layoutIfNeeded()
    })
  }
}

private extension InteractiveSheetViewController {
  func setupMainView() {
    let mainView = mainViewController.view!
    mainView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(mainView)
    activate(
      mainView.topAnchor.constraint(equalTo: view.topAnchor),
      mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    )
  }

  func setupOverlayView() {
    let overlayView = overlayViewController.view!
    overlayView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(overlayView)
    heightConstraint = overlayView.heightAnchor.constraint(equalToConstant: overlayViewController.compactHeight)
    activate(
      heightConstraint,
      overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: overlayBottomOffset)
    )
  }
}

extension InteractiveSheetViewController: OverlayControllerDelegate {
  var currentHeight: CGFloat {
    return heightConstraint.constant
  }

  var switchStateThreshold: CGFloat {
    return view.bounds.height / 2 + overlayViewController.compactHeight
  }

  var fullscreenOverlayHeight: CGFloat {
    return view.bounds.height - view.safeAreaInsets.top + overlayBottomOffset
  }

  var compactOverlayHeight: CGFloat {
    return overlayViewController.compactHeight + overlayBottomOffset
  }

  func shouldSetHeight(_ height: CGFloat, animated: Bool) {
    heightConstraint.constant = height
    guard animated else {
      if height < switchStateThreshold {
        overlayViewController.notifyCompact()
      }
      return
    }
    let animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut)
    animator.addAnimations {
      self.view.layoutIfNeeded()
    }
    if height < switchStateThreshold {
      animator.addCompletion { _ in
        self.overlayViewController.notifyCompact()
      }
    }
    animator.startAnimation()
  }

  func didChangeState(_ newState: OverlayStateController.State, animated _: Bool) {
    if case .compact = newState {
      overlayViewController.notifyCompact()
    }
  }
}

extension InteractiveSheetViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_: UITextField) {
    if overlayStateController.state == .compact {
      overlayStateController.set(.fullScreen, animated: true)
    }
  }
}
