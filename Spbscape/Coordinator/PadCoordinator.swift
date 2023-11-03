//
//  PadCoordinator.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 03.11.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import SpbscapeCore
import SwiftUI

final class PadCoordinator: Coordinator {

  let viewControllerFactory: ViewControllerFactory
  let splitViewController: UISplitViewController
  var detailsTransitioningDelegate: TransitioningDelegate!
  let toolbarDelegate: ToolbarDelegate

  init() {
    let viewModelFactory = ViewModelFactory()
    self.viewControllerFactory = ViewControllerFactory(viewModelFactory: viewModelFactory)
    if #available(macCatalyst 14.0, iOS 14.0, *) {
      self.splitViewController = UISplitViewController(style: .doubleColumn)
      splitViewController.primaryBackgroundStyle = .sidebar
      splitViewController.presentsWithGesture = false
      splitViewController.preferredDisplayMode = .oneBesideSecondary
    } else {
      splitViewController = UISplitViewController()
    }
    self.toolbarDelegate = ToolbarDelegate()
    viewModelFactory.searchViewModel().searcher.search()
  }

  #if targetEnvironment(macCatalyst)
  lazy var toolbar: NSToolbar = {
    let toolbar = NSToolbar(identifier: "main")
    toolbar.delegate = toolbarDelegate
    toolbar.displayMode = .iconOnly
    return toolbar
  }()
  #endif

  func rootViewController() -> UIViewController {
    splitViewController
  }

  func presentRoot() {
    let mapHitsViewController = viewControllerFactory.hitsMapViewController()
    let listHitsViewController = viewControllerFactory.hitsListViewController()
    let searchViewController = viewControllerFactory.searchViewController(with: listHitsViewController)
    if #available(macCatalyst 14.0, iOS 14.0, *) {
      splitViewController.setViewController(searchViewController, for: .primary)
      splitViewController.setViewController(mapHitsViewController, for: .secondary)
    } else {
      splitViewController.viewControllers = [
        searchViewController,
        UINavigationController(rootViewController: mapHitsViewController)
      ]
    }
    searchViewController.navigationController?.isNavigationBarHidden = true
    // For macOS a system toolbar presented, for iPadOS a classic navigation bar
#if targetEnvironment(macCatalyst)
    searchViewController.showFilterSubscriber = NotificationCenter.default.publisher(for: .showFilters)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] _ in
        self?.presentFilters(from: .init(x: 50, y: 50, width: 40, height: 40))
      })
#else
    let toolpanelViewController = mapHitsViewController.toolpanelViewController
    mapHitsViewController.navigationController?.isNavigationBarHidden = true
    toolpanelViewController?.didTapFiltersButton = { [weak self, weak mapHitsViewController] button in
      let sourceRect = mapHitsViewController?.view.convert(button.frame,
                                                           from: button.superview)
      self?.presentFilters(from: sourceRect)
    }
#endif
    listHitsViewController.didSelect = { [weak mapHitsViewController] building in
      mapHitsViewController?.highlight(building)
    }

    mapHitsViewController.didSelect = { [weak self] building, _ in
      self?.presentBuilding(building)
    }
  }

  var secondaryViewController: UIViewController {
    splitViewController.viewControllers.last!
  }

  func presentFilters(from sourceRect: CGRect? = nil) {
    let filtersViewController = viewControllerFactory.filtersViewController()
    let filtersNavigationController = UINavigationController(rootViewController: filtersViewController)
    let navigationBarAppearance = UINavigationBarAppearance()
    navigationBarAppearance.configureWithOpaqueBackground()
    filtersNavigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    if #available(iOS 15.0, *) {
      let toolBarAppearance = UIToolbarAppearance()
      toolBarAppearance.configureWithOpaqueBackground()
      filtersNavigationController.toolbar.scrollEdgeAppearance = toolBarAppearance
    }
    filtersNavigationController.modalPresentationStyle = .popover
    filtersNavigationController.preferredContentSize = CGSize(width: 300,
                                                              height: 500)
    filtersNavigationController.popoverPresentationController?.sourceView = secondaryViewController.view
    #if targetEnvironment(macCatalyst)
    if #available(macCatalyst 16.0, *) {
      filtersNavigationController.popoverPresentationController?.sourceItem = toolbar.items.last
    }
    #endif
    if let sourceRect = sourceRect {
      filtersNavigationController.popoverPresentationController?.sourceRect = sourceRect
    }

    secondaryViewController.present(filtersNavigationController, animated: true)
  }

  func presentBuilding(_ building: Building) {
    func presentBuilding(mode: TransitioningDelegate.Mode) {
      let buildingViewController = viewControllerFactory.buildingViewController(for: building)
      let navigationController = UINavigationController(rootViewController: buildingViewController)
      navigationController.modalPresentationStyle = .custom
      let view = UIView(autolayout: ())
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
      secondaryViewController.present(navigationController, animated: true) {
        self.detailsTransitioningDelegate.presentController.mode = .slide
        self.detailsTransitioningDelegate.dismissController.mode = .slide
      }
    }

    if let presentedViewController = secondaryViewController.presentedViewController {
      detailsTransitioningDelegate.dismissController.mode = .fade
      presentedViewController.dismiss(animated: true) {
        presentBuilding(mode: .fade)
      }
    } else {
      presentBuilding(mode: .slide)
    }
  }

}
