//
//  SceneDelegate+Pad.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 21/03/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

extension SceneDelegate {
  
  static func buildRootPadViewController(listHitsViewController: BuldingHitsListViewController,
                                         mapHitsViewController: BuldingHitsMapViewController,
                                         searchViewModel: SearchViewModel,
                                         filterHelper: FiltersHelper) -> UIViewController {
    
    filterHelper.sourceViewController = mapHitsViewController
    
    let sidebarViewController = SearchViewController(childViewController: listHitsViewController)
    sidebarViewController.handleView.isHidden = true
    sidebarViewController.hitsCountView.isHidden = true
    sidebarViewController.filterButton.isHidden = true
    searchViewModel.configure(sidebarViewController.searchTextField)
        
    let splitViewController: UISplitViewController
    if #available(macCatalyst 14.0, iOS 14.0, *) {
      splitViewController = UISplitViewController(style: .doubleColumn)
      splitViewController.primaryBackgroundStyle = .sidebar
      splitViewController.presentsWithGesture = false
      splitViewController.preferredDisplayMode = .allVisible
      splitViewController.setViewController(sidebarViewController, for: .primary)
      splitViewController.setViewController(mapHitsViewController, for: .secondary)
    } else {
      splitViewController = .init()
      splitViewController.viewControllers = [
        sidebarViewController,
//        UINavigationController(rootViewController: sidebarViewController),
        UINavigationController(rootViewController: mapHitsViewController)
      ]
    }
    
    sidebarViewController.navigationController?.isNavigationBarHidden = true
    // For macOS a system toolbar presented, for iPadOS a classic navigation bar
    #if targetEnvironment(macCatalyst)
    mapHitsViewController.navigationController?.isNavigationBarHidden = true
    #else
    
    mapHitsViewController.navigationItem.rightBarButtonItems = [
      splitViewController.displayModeButtonItem,
      filterHelper.filterBarButtonItem,
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      searchViewModel.hitsCountBarButtonItem()
    ]
    #endif
    
    listHitsViewController.didSelect = { [weak mapHitsViewController] building in
      mapHitsViewController?.highlight(building)
    }
    
    mapHitsViewController.didSelect = { [weak mapHitsViewController] building, view in
//      mapHitsViewController?.presentPopover(for: building, from: view)
      guard let mapHitsViewController = mapHitsViewController else { return }
      mapHitsViewController.presentSidebar(for: building)
//      mapHitsViewController.presentWindow(for: building)
    }

    
    searchViewModel.searcher.search()
    return splitViewController
  }
  
}

import SpbscapeCore

extension BuldingHitsMapViewController {
    
  func presentSidebar(for building: Building) {
    
    func presentBuilding(mode: TransitioningDelegate.Mode) {
      let buildingViewController = BuildingViewController(building: building)
      let navigationController = UINavigationController(rootViewController: buildingViewController)
      navigationController.modalPresentationStyle = .custom
      let view = UIView()
      view.translatesAutoresizingMaskIntoConstraints = false
      view.backgroundColor = .separator
      view.widthAnchor.constraint(equalToConstant: 0.7).isActive = true
      navigationController.view.addSubview(view)
      view.leadingAnchor.constraint(equalTo: navigationController.view.leadingAnchor).isActive = true
      view.heightAnchor.constraint(equalTo: navigationController.view.heightAnchor).isActive = true
      view.topAnchor.constraint(equalTo: navigationController.view.topAnchor).isActive = true
      view.bottomAnchor.constraint(equalTo: navigationController.view.bottomAnchor).isActive = true
      let transitioningDelegate = TransitioningDelegate()
      transitioningDelegate.presentController.mode = mode
      detailsTransitioningDelegate = transitioningDelegate
      navigationController.transitioningDelegate = transitioningDelegate
      present(navigationController, animated: true) {
        self.detailsTransitioningDelegate.presentController.mode = .slide
        self.detailsTransitioningDelegate.dismissController.mode = .slide
      }
    }
    
    if let presentedViewController = presentedViewController {
      detailsTransitioningDelegate.dismissController.mode = .fade
      presentedViewController.dismiss(animated: true) {
        presentBuilding(mode: .fade)
      }
    } else {
      presentBuilding(mode: .slide)
    }

  }
  
}


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

  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      return presentController
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      return dismissController
  }
  
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    return SidebarOverlayPresentationController(presentedViewController: presented, presenting: presenting)
  }
  
}

class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  
  var mode: TransitioningDelegate.Mode = .slide
    
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
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


class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  
  var mode: TransitioningDelegate.Mode = .slide

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
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


class SidebarOverlayPresentationController: UIPresentationController {
  
  override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(pan:)))
    presentedViewController.view.addGestureRecognizer(panGesture)
  }
  
  @objc func didPan(pan: UIPanGestureRecognizer) {
      guard let view = pan.view,
            let superView = view.superview,
            let presented = presentedView,
            let container = containerView else { return }
      
//    print(pan.translation(in: presentingViewController.view))
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
//    container.isUserInteractionEnabled = false
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
