//
//  FiltersHelper.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 14/03/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

final class FiltersHelper {
  
  let searchViewModel: SearchViewModel
  var buildFilterViewController: (() -> UIViewController)?
  weak var sourceViewController: UIViewController?
  
  lazy var filterBarButtonItem: UIBarButtonItem = .init(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(presentFilters))

  
  init(searchViewModel: SearchViewModel) {
    self.searchViewModel = searchViewModel
    searchViewModel.filterState.onChange.subscribePast(with: filterBarButtonItem) { (item, filterState) in
      let iconName = filterState.toFilterGroups().map(\.filters).allSatisfy(\.isEmpty) ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill"
      item.image = UIImage(systemName: iconName)
    }.onQueue(.main)
  }

  @objc
  func presentFilters() {
    guard let sourceViewController = sourceViewController else { return }
    let filtersViewController = UINavigationController(rootViewController: FilterViewController(filterState: searchViewModel.filterState, hitsCountBarButtonItem: searchViewModel.hitsCountBarButtonItem()))
    let navigationBarAppearance = UINavigationBarAppearance()
    navigationBarAppearance.configureWithOpaqueBackground()
    filtersViewController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    let toolBarAppearance = UIToolbarAppearance()
    toolBarAppearance.configureWithOpaqueBackground()
    if #available(iOS 15.0, *) {
      filtersViewController.toolbar.scrollEdgeAppearance = toolBarAppearance
    }
    switch UIDevice.current.userInterfaceIdiom {
    case .pad:
      filtersViewController.modalPresentationStyle = .popover
      filtersViewController.preferredContentSize = .init(width: 300, height: 400)
      #if targetEnvironment(macCatalyst)
      filtersViewController.popoverPresentationController?.sourceView = sourceViewController.view
      filtersViewController.popoverPresentationController?.sourceRect = .init(x: sourceViewController.view.bounds.width - 50, y: 20, width: 32, height: 32)
      #else
      filtersViewController.popoverPresentationController?.barButtonItem = filterBarButtonItem
      #endif
    default:
      break
    }
    
    sourceViewController.present(filtersViewController, animated: true, completion: nil)
  }
}
