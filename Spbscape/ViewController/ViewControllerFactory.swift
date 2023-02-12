//
//  ViewControllerFactory.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 11.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import AlgoliaSearchClient
import UIKit

final class ViewControllerFactory {
  
  static func toolpanelViewController(searchViewModel: SearchViewModel) -> ToolpanelViewController? {
#if targetEnvironment(macCatalyst)
    return nil
#else
    guard UIDevice.current.userInterfaceIdiom != .phone else {
      return nil
    }
    return ToolpanelViewController(filtersStateViewModel: searchViewModel.filtersStateViewModel,
                                   resultsCountViewModel: searchViewModel.resultsCountViewModel)
#endif
  }
  
  static func searchViewController(with listHitsViewController: UIViewController,
                                   searchViewModel: SearchViewModel) -> SearchViewController {
    let searchViewController: SearchViewController
    let style: SearchViewController.Style = UIDevice.current.userInterfaceIdiom == .phone ? .overlay : .fullscreen
    searchViewController = SearchViewController(childViewController: listHitsViewController,
                                                filtersStateViewModel: searchViewModel.filtersStateViewModel,
                                                resultsCountViewModel: searchViewModel.resultsCountViewModel,
                                                style: style)
    searchViewModel.setup(searchViewController)
    return searchViewController
  }
  
  static func hitsMapViewController(searchViewModel: SearchViewModel) -> BuldingHitsMapViewController {
    let toolpanelViewController = toolpanelViewController(searchViewModel: searchViewModel)
    let mapHitsViewController = BuldingHitsMapViewController(toolpanelViewController: toolpanelViewController)
    mapHitsViewController.didChangeVisibleRegion = { [weak searchViewModel, weak mapHitsViewController] visibleRect, byUser in
      guard let searchViewModel = searchViewModel, byUser else { return }
      if let mapView = mapHitsViewController?.mapView {
        searchViewModel.searcher.request.query.aroundPrecision = [AroundPrecision(from: 0, value: mapView.region.sizeInMeters.h)]
        searchViewModel.searcher.request.query.aroundLatLng = Point(mapView.centerCoordinate)
      }
      searchViewModel.searcher.request.query.aroundRadius = .all
      searchViewModel.searcher.search()
    }
    searchViewModel.hitsConnector.connectController(mapHitsViewController)
    return mapHitsViewController
  }
  
  static func hitsListViewController(searchViewModel: SearchViewModel) -> BuldingHitsListViewController {
    let listHitsViewController = BuldingHitsListViewController()
    searchViewModel.hitsConnector.connectController(listHitsViewController)
    return listHitsViewController
  }
  
  static func filtersViewController(searchViewModel: SearchViewModel) -> FiltersViewController {
    let resultsCountViewModel: ResultsCountViewModel?
#if targetEnvironment(macCatalyst)
    resultsCountViewModel = searchViewModel.resultsCountViewModel
#else
    if UIDevice.current.userInterfaceIdiom == .phone {
      resultsCountViewModel = searchViewModel.resultsCountViewModel
    } else {
      resultsCountViewModel = nil
    }
#endif
    let filtersViewController = FiltersViewController(filtersStateViewModel: searchViewModel.filtersStateViewModel,
                                                      resultsCountViewModel: resultsCountViewModel)
    searchViewModel.filtersViewModel.setup(filtersViewController)
    return filtersViewController
  }
  
  static func rootViewController(searchViewModel: SearchViewModel) -> UIViewController {
    let mapHitsViewController = hitsMapViewController(searchViewModel: searchViewModel)
    let listHitsViewController = hitsListViewController(searchViewModel: searchViewModel)
    let searchViewController = searchViewController(with: listHitsViewController,
                                                    searchViewModel: searchViewModel)
    if UIDevice.current.userInterfaceIdiom == .phone {
      return rootPhoneViewController(searchViewController: searchViewController,
                                     listHitsViewController: listHitsViewController,
                                     mapHitsViewController: mapHitsViewController,
                                     searchViewModel: searchViewModel)
    } else {
      return rootPadViewController(searchViewController: searchViewController,
                                   listHitsViewController: listHitsViewController,
                                   mapHitsViewController: mapHitsViewController,
                                   searchViewModel: searchViewModel)
    }
  }
  
  private static func rootPadViewController(searchViewController: SearchViewController,
                                            listHitsViewController: BuldingHitsListViewController,
                                            mapHitsViewController: BuldingHitsMapViewController,
                                            searchViewModel: SearchViewModel) -> UIViewController {
    
    let splitViewController: UISplitViewController
    if #available(macCatalyst 14.0, iOS 14.0, *) {
      splitViewController = UISplitViewController(style: .doubleColumn)
      splitViewController.primaryBackgroundStyle = .sidebar
      splitViewController.presentsWithGesture = false
      splitViewController.preferredDisplayMode = .allVisible
      splitViewController.setViewController(searchViewController, for: .primary)
      splitViewController.setViewController(mapHitsViewController, for: .secondary)
    } else {
      splitViewController = UISplitViewController()
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
      .sink(receiveValue: { [weak searchViewModel, weak mapHitsViewController] notification in
        guard let searchViewModel, let mapHitsViewController else { return }
        let filtersViewController = filtersViewController(searchViewModel: searchViewModel)
        mapHitsViewController.present(filtersViewController)
      })
#else
    mapHitsViewController.navigationController?.isNavigationBarHidden = true
    mapHitsViewController.toolpanelViewController?.didTapFiltersButton = { [weak searchViewModel, weak mapHitsViewController] filtersButton in
      guard let searchViewModel, let mapHitsViewController else { return }
      let sourceRect = mapHitsViewController.view.convert(filtersButton.frame,
                                                          from: filtersButton.superview)
      let filtersViewController = ViewControllerFactory.filtersViewController(searchViewModel: searchViewModel)
      mapHitsViewController.present(filtersViewController, from: sourceRect)
    }
#endif
    listHitsViewController.didSelect = { [weak mapHitsViewController] building in
      mapHitsViewController?.highlight(building)
    }
    
    mapHitsViewController.didSelect = { [weak mapHitsViewController] building, _ in
      guard let mapHitsViewController else { return }
      mapHitsViewController.presentSidebar(for: building)
    }
    return splitViewController
  }
  
  private static func rootPhoneViewController(searchViewController: SearchViewController,
                                              listHitsViewController: BuldingHitsListViewController,
                                              mapHitsViewController: BuldingHitsMapViewController,
                                              searchViewModel: SearchViewModel) -> UIViewController {
    
    let interactiveSheetViewController = InteractiveSheetViewController(mainViewController: mapHitsViewController,
                                                                        overlayViewController: searchViewController,
                                                                        compactHeight: searchViewController.compactHeight,
                                                                        searchTextField: searchViewController.searchTextField)
    searchViewController.didTapFilterButton = { [weak interactiveSheetViewController, weak searchViewModel] _ in
      guard let interactiveSheetViewController, let searchViewModel else { return }
      let filtersViewController = ViewControllerFactory.filtersViewController(searchViewModel: searchViewModel)
      interactiveSheetViewController.present(filtersViewController)
    }
    
    let navigationController = UINavigationController(rootViewController: interactiveSheetViewController)
    mapHitsViewController.didSelect = { [weak navigationController] building, _ in
      let buildingViewController = BuildingViewController(building: building)
      buildingViewController.view.backgroundColor = .systemBackground
      navigationController?.pushViewController(buildingViewController, animated: true)
    }
    
    listHitsViewController.didSelect = { [weak navigationController] building in
      let buildingViewController = BuildingViewController(building: building)
      buildingViewController.view.backgroundColor = .systemBackground
      navigationController?.pushViewController(buildingViewController, animated: true)
    }
    return navigationController
  }
  
}