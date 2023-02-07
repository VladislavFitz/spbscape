//
//  UIViewController+Filters.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 14/03/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore

extension UIViewController {
  
  func presentFilters(viewControllerBuilder: () -> FiltersViewController,
                      sourceRect: CGRect? = nil) {
    let filterViewController = viewControllerBuilder()
    let filtersNavigationController = UINavigationController(rootViewController: filterViewController)
    let navigationBarAppearance = UINavigationBarAppearance()
    navigationBarAppearance.configureWithOpaqueBackground()
    filtersNavigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance

    if #available(iOS 15.0, *) {
      let toolBarAppearance = UIToolbarAppearance()
      toolBarAppearance.configureWithOpaqueBackground()
      filtersNavigationController.toolbar.scrollEdgeAppearance = toolBarAppearance
    }

    switch UIDevice.current.userInterfaceIdiom {
    case .pad:
      filtersNavigationController.modalPresentationStyle = .popover
      filtersNavigationController.preferredContentSize = CGSize(width: 300,
                                                                height: 500)
      filtersNavigationController.popoverPresentationController?.sourceView = view
      if let sourceRect = sourceRect {
          filtersNavigationController.popoverPresentationController?.sourceRect = sourceRect
      }
    default:
      break
    }
    
    present(filtersNavigationController,
            animated: true,
            completion: nil)
  }
  
}
