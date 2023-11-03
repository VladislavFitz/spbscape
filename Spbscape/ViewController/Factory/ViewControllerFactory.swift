//
//  ViewControllerFactory.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 11.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import AlgoliaSearchClient
import Foundation
import SpbscapeCore
import SwiftUI
import UIKit

class ViewControllerFactory {
  
  let viewModelFactory: ViewModelFactory
  
  init(viewModelFactory: ViewModelFactory) {
    self.viewModelFactory = viewModelFactory
  }
  
  func toolpanelViewController() -> ToolpanelViewController? {
#if targetEnvironment(macCatalyst)
    return nil
#else
    guard UIDevice.current.userInterfaceIdiom != .phone else {
      return nil
    }
    return ToolpanelViewController(filtersStateViewModel: viewModelFactory.filtersStateViewModel(),
                                   resultsCountViewModel: viewModelFactory.resultsCountViewModel())
#endif
  }
  
  func searchHeaderViewController() -> SearchHeaderViewController {
    let style: SearchHeaderViewController.Style = UIDevice.current.userInterfaceIdiom == .phone ? .overlay : .fullscreen
    return SearchHeaderViewController(filtersStateViewModel: viewModelFactory.filtersStateViewModel(),
                                      resultsCountViewModel: viewModelFactory.resultsCountViewModel(),
                                      style: style)
  }
  
  func searchViewController(with bodyViewController: UIViewController) -> SearchViewController {
    let headerViewController = searchHeaderViewController()
    let searchViewController = SearchViewController(headerViewController: headerViewController,
                                                    bodyViewController: bodyViewController)
    viewModelFactory.searchViewModel().setup(searchViewController)
    return searchViewController
  }
  
  func hitsMapViewController() -> BuldingHitsMapViewController {
    let searchViewModel = viewModelFactory.searchViewModel()
    let toolpanelViewController = toolpanelViewController()
    let mapHitsViewController = BuldingHitsMapViewController(toolpanelViewController: toolpanelViewController)
    mapHitsViewController.didChangeVisibleRegion = { [weak searchViewModel, weak mapHitsViewController] _, byUser in
      guard let searchViewModel = searchViewModel, byUser else { return }
      if let mapView = mapHitsViewController?.mapView {
        searchViewModel.searcher.request.query.aroundPrecision = [
          AroundPrecision(from: 0, value: mapView.region.sizeInMeters.h)
        ]
        searchViewModel.searcher.request.query.aroundLatLng = Point(mapView.centerCoordinate)
      }
      searchViewModel.searcher.request.query.aroundRadius = .all
      searchViewModel.searcher.search()
    }
    searchViewModel.hitsConnector.connectController(mapHitsViewController)
    return mapHitsViewController
  }
  
  func hitsListViewController() -> BuldingHitsListViewController {
    let viewModel = viewModelFactory.searchViewModel()
    let listHitsViewController = BuldingHitsListViewController()
    viewModel.hitsConnector.connectController(listHitsViewController)
    return listHitsViewController
  }
  
  func filtersViewController() -> FiltersViewController {
    let resultsCountViewModel: ResultsCountViewModel?
#if targetEnvironment(macCatalyst)
    resultsCountViewModel = viewModelFactory.resultsCountViewModel()
#else
    if UIDevice.current.userInterfaceIdiom == .phone {
      resultsCountViewModel = viewModelFactory.resultsCountViewModel()
    } else {
      resultsCountViewModel = nil
    }
#endif
    let filtersViewController = FiltersViewController(filtersStateViewModel: viewModelFactory.filtersStateViewModel(),
                                                      resultsCountViewModel: resultsCountViewModel)
    viewModelFactory.searchViewModel().filtersViewModel.setup(filtersViewController)
    return filtersViewController
  }
  
  func buildingViewController(for building: Building) -> UIViewController {
    let viewModel = BuildingViewModel(building: building)
    let view = BuildingView(viewModel: viewModel)
    let hostingViewController = UIHostingController(rootView: view)
    return hostingViewController
  }
  
}
