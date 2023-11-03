//
//  PhoneCoordinator.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 03.11.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import SpbscapeCore
import SwiftUI
import UIKit

final class PhoneCoordinator: Coordinator {

  let viewControllerFactory: ViewControllerFactory
  let navigationController: UINavigationController

  init() {
    let viewModelFactory = ViewModelFactory()
    self.viewControllerFactory = ViewControllerFactory(viewModelFactory: viewModelFactory)
    self.navigationController = UINavigationController()
    viewModelFactory.searchViewModel().searcher.search()
  }

  func rootViewController() -> UIViewController {
    navigationController
  }

  func presentRoot() {
    let mapHitsViewController = viewControllerFactory.hitsMapViewController()
    let listHitsViewController = viewControllerFactory.hitsListViewController()
    let searchViewController = viewControllerFactory.searchViewController(with: listHitsViewController)
    let interactiveSheetViewController = InteractiveSheetViewController(mainViewController: mapHitsViewController,
                                                                        overlayViewController: searchViewController)
    searchViewController.headerViewController.searchTextField.delegate = interactiveSheetViewController
    searchViewController.headerViewController.didTapFilterButton = { [weak self] _ in
      self?.presentFilters()
    }
    mapHitsViewController.didSelect = { [weak self] building, _ in
      self?.presentBuilding(building)
    }
    listHitsViewController.didSelect = { [weak self] building in
      self?.presentBuilding(building)
    }
    navigationController.pushViewController(interactiveSheetViewController, animated: false)
  }

  func presentFilters() {
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
    navigationController.present(filtersNavigationController,
                                 animated: true)
  }

  func presentBuilding(_ building: Building) {
    let buildingViewController = viewControllerFactory.buildingViewController(for: building)
    navigationController.present(buildingViewController,
                                 animated: true)
  }

}
