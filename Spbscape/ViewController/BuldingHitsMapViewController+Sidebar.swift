//
//  BuldingHitsMapViewController+Sidebar.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 05.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import SpbscapeCore

extension BuldingHitsMapViewController {
    
  func presentSidebar(for building: Building) {
    
    func presentBuilding(mode: TransitioningDelegate.Mode) {
      let viewModel = BuildingViewModel(building: building)
      let buildingViewController = UIHostingController(rootView: BuildingView(viewModel: viewModel))
      //BuildingViewController(building: building)
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
