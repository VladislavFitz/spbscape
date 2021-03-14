//
//  MainSplitViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 08/11/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearch
import MapKit
import CityWallsCore
import Geohash
import Combine

final class MainSplitViewController: UISplitViewController {
  
  var mode: Mode = .list
  
  enum Mode {
    case list
    case map
    
    var nextMode: Mode {
      switch self {
      case .list:
        return .map
      case .map:
        return .list
      }
    }
    
    var buttonImage: UIImage? {
      let symbolName: String
      switch self {
      case .list:
        symbolName = "list.dash"
      case .map:
        symbolName = "map"
      }
      return UIImage(systemName: symbolName)
    }
    
    var controllerIndex: Int {
      switch self {
      case .list:
        return 0
      case .map:
        return 1
      }
    }
    
  }
  
  let searchViewModel: SearchViewModel
  let masterViewController: MasterSearchViewController
  let mapViewController: BuldingHitsMapViewController
  let buildingHitsController: BuldingHitsListViewController
  
  lazy var hitsContainerController: ContainerViewController = {
    return .init(viewControllers: [buildingHitsController, mapViewController])
  }()

  let searchInRegionButton: UIButton
  let searchNearMeButton: UIButton
  
  lazy var hitsCountBarButtonItem: UIBarButtonItem = .init(title: "Зданий: 0", style: .done, target: nil, action: nil)
  
  lazy var filterBarButtonItem: UIBarButtonItem = .init(image: UIImage(systemName: "line.horizontal.3.decrease"), style: .plain, target: self, action: #selector(didTapFilterButton))

  
  var regionSelected: MKMapRect?
  var buildingInFocus: Building?
  
  @objc func didTapFilterButton() {
    presentFilters()
  }

  
  lazy var switchAppearanceModeBarButtonItem: UIBarButtonItem = .init(image: UIImage(systemName: "map"), style: .done, target: self, action: #selector(didSwitchMode))

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    buildingHitsController = .init()
    let searchBar = UISearchTextField()
    searchViewModel = .init(textField: searchBar)
    self.mapViewController = .init()
    let hitsController: UIViewController
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
      hitsController = ContainerViewController(viewControllers: [buildingHitsController, mapViewController])
    default:
      hitsController = buildingHitsController
    }
    self.masterViewController = .init(searchBar: searchBar,
                                      hitsController: hitsController,
                                      searchViewModel: searchViewModel)
    self.searchInRegionButton = UIButton()
    self.searchNearMeButton = UIButton()
    if #available(macCatalyst 14.0, iOS 14.0, *) {
      super.init(style: .doubleColumn)
      primaryBackgroundStyle = .sidebar
      preferredDisplayMode = .primaryOverlay
    } else {
      super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    buildingHitsController.view.translatesAutoresizingMaskIntoConstraints = false
    masterViewController.searchViewModel.hitsConnector.interactor.connectController(buildingHitsController)
    
    masterViewController.searchViewModel.searcher.onResults.subscribe(with: self) { (vc, response) in
      response.facets.flatMap(vc.process)
    }
  }
  
  func process(_ facets: [Attribute: [Facet]]) {
    mapViewController.hashFacets = facets
  }
  
  private var showFilterSubscriber: AnyCancellable?
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func select(_ building: Building) {

//    if let buildingInFocus = buildingInFocus, buildingInFocus.id == building.id {
//      let buildingViewController = BuildingViewController(building: building)
//      present(buildingViewController, animated: true, completion: nil)
//    } else {
//      buildingHitsController.highlight(building)
//      mapViewController.highlight(building)
//      buildingInFocus = building
//    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if #available(macCatalyst 14.0, iOS 14.0, *) {
      if UIDevice.current.userInterfaceIdiom == .phone {
        show(.primary)
      }
    }
  }
      
  override func viewDidLoad() {
    super.viewDidLoad()
    
    buildingHitsController.tableView.keyboardDismissMode = .interactive
    masterViewController.searchViewModel.hitsConnector.interactor.connectController(mapViewController)
    
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
      if #available(macCatalyst 14.0, iOS 14.0, *) {
        setViewController(masterViewController, for: .primary)
      } else {
        viewControllers = [UINavigationController(rootViewController: masterViewController)]
      }
    case .pad:
      if #available(macCatalyst 14.0, iOS 14.0, *) {
        setViewController(masterViewController, for: .primary)
        setViewController(mapViewController, for: .secondary)
      } else {
        viewControllers = [UINavigationController(rootViewController: masterViewController), mapViewController]
      }
      #if targetEnvironment(macCatalyst)
      // For macOS a system toolbar presented
      mapViewController.navigationController?.isNavigationBarHidden = true
      #endif
      mapViewController.navigationItem.rightBarButtonItems = [filterBarButtonItem, UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil), hitsCountBarButtonItem]
    default:
      break
    }
    (masterViewController.searchViewModel.hitsConnector.searcher as? SingleIndexSearcher)?.indexQueryState.query.hitsPerPage = 100
    mapViewController.didChangeVisibleRegion = { [weak self] visibleRect in
      guard let vc = self else { return }
      vc.masterViewController.searchViewModel.searcher.indexQueryState.query.aroundLatLng = .init(.init(vc.mapViewController.mapView.centerCoordinate))
      vc.masterViewController.searchViewModel.searcher.indexQueryState.query.aroundRadius = .all
      vc.masterViewController.searchViewModel.searcher.search()
    }
    mapViewController.didSelect = { [weak self] building, annotation in
      let buildingViewController = BuildingViewController(building: building)
      buildingViewController.modalPresentationStyle = .popover
      buildingViewController.popoverPresentationController?.sourceView = annotation
      buildingViewController.popoverPresentationController?.sourceRect = annotation.bounds.insetBy(dx: annotation.centerOffset.x, dy: annotation.centerOffset.y)
      self?.present(buildingViewController, animated: true, completion: nil)
    }
    
    masterViewController.toolbarItems = [
      switchAppearanceModeBarButtonItem,
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      hitsCountBarButtonItem,
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      filterBarButtonItem
    ]
    buildingHitsController.didSelect = { [weak self] building in
      self?.select(building)
    }
    
    searchViewModel.searcher.onResults.subscribe(with: self) { (vc, response) in
      vc.hitsCountBarButtonItem.title = "Зданий: \(response.searchStats.totalHitsCount)"
    }.onQueue(.main)

    
    mapViewController.mapView.showsUserLocation = true
    
    showFilterSubscriber = NotificationCenter.default.publisher(for: .showFilters)
          .receive(on: RunLoop.main)
          .sink(receiveValue: { [weak self] notification in
              guard let self = self else { return }
            self.presentFilters()
          })
    
    masterViewController.navigationController?.isNavigationBarHidden = true

  }
      
  @objc func didSwitchMode(_ barButtonItem: UIBarButtonItem) {
    toggleMode()
  }
  
  func toggleMode() {
    mode = mode == .list ? .map : .list
    switchAppearanceModeBarButtonItem.image = mode.nextMode.buttonImage
    hitsContainerController.setVisibleViewController(atIndex: mode.controllerIndex)
  }
  
  func presentFilters() {
    let filterViewController = FilterViewController(filterState: searchViewModel.filterState)
    let navigationController = UINavigationController(rootViewController: filterViewController)
    searchViewModel.searcher.onResults.subscribePast(with: filterViewController) { (filterViewController, response) in
      filterViewController.hitsCountBarButtonItem.title = "Зданий: \(response.searchStats.totalHitsCount)"
    }.onQueue(.main)
    #if targetEnvironment(macCatalyst)
    navigationController.modalPresentationStyle = .popover
    navigationController.popoverPresentationController?.sourceView = mapViewController.view
    navigationController.popoverPresentationController?.sourceRect = .init(x: mapViewController.view.bounds.width - 50, y: 20, width: 32, height: 32)
    #else
    navigationController.modalPresentationStyle = .popover
    navigationController.popoverPresentationController?.barButtonItem = filterBarButtonItem
    #endif

    present(navigationController, animated: true, completion: nil)
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    print(traitCollection)
  }
  
}
