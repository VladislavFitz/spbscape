//
//  MainSplitViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 08/11/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
//import InstantSearch
import MapKit
import CityWallsCore

final class MainSplitViewController: UISplitViewController {
  
  var mode: Mode = .list
  
  enum Mode {
    case list
    case map
  }
  
  let masterViewController: MasterSearchViewController
  let mapViewController: BuldingHitsMapViewController
  let searchInRegionButton: UIButton
  let searchNearMeButton: UIButton
  
  var regionSelected: MKMapRect?
  var buildingInFocus: Building?
  
  lazy var switchAppearanceModeBarButtonItem: UIBarButtonItem = .init(image: UIImage(systemName: "map"), style: .done, target: self, action: #selector(didSwitchMode))

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.masterViewController = .init()
    self.mapViewController = .init()
    self.searchInRegionButton = UIButton()
    self.searchNearMeButton = UIButton()
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func select(_ building: Building) {
    if let buildingInFocus = buildingInFocus, buildingInFocus.id == building.id {
      let buildingViewController = BuildingViewController(building: building)
      present(buildingViewController, animated: true, completion: nil)
    } else {
      masterViewController.buildingHitsController.highlight(building)
      mapViewController.highlight(building)
      buildingInFocus = building
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    masterViewController.buildingHitsController.tableView.keyboardDismissMode = .interactive
    masterViewController.searchController.searchBar.showsScopeBar = true
    try! masterViewController.hitsConnector.interactor.hitsInteractor(forSection: 0).connectController(mapViewController)
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
      masterViewController.navigationItem.rightBarButtonItem = switchAppearanceModeBarButtonItem
      viewControllers = [UINavigationController(rootViewController: masterViewController)]
    case .pad, .mac:
      viewControllers = [UINavigationController(rootViewController: masterViewController), mapViewController]
    default:
      break
    }
    masterViewController.hitsConnector.searcher.indexQueryStates[0].query.hitsPerPage = 1000
    mapViewController.didChangeVisibleRegion = { _ in
      self.searchInRegionButton.isHidden = false
    }
    mapViewController.didSelect = { [weak self] building in
      self?.select(building)
    }
    
    masterViewController.buildingHitsController.didSelect = { [weak self] building in
      self?.select(building)
    }
    
    mapViewController.view.addSubview(searchInRegionButton)
    activate(
      searchInRegionButton.centerXAnchor.constraint(equalTo: mapViewController.view.safeAreaLayoutGuide.centerXAnchor),
      searchInRegionButton.bottomAnchor.constraint(equalTo: mapViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -2)
    )
    configureSearchInRegionButton()
    mapViewController.mapView.showsUserLocation = true
//    configureHitsCountLabel()
    
//    masterViewController.hitsConnector.searcher.onResults.subscribe(with: self) { (viewController, response) in
//      let hitsCount = response.results.first?.searchStats.totalHitsCount ?? 0
//      viewController.hitsCountLabel.text = "\(hitsCount) hits"
//    }.onQueue(.main)
  }
  
  @objc func didTapSearchInRegionButton(_ sender: Any) {
    searchInRegionButton.isHidden = true
    masterViewController.searchInRect(mapViewController.mapView.visibleMapRect)
  }
  
  @objc func didTapSearchNearMeButon(_ sender: Any) {
//    mapViewController.
  }
  
  @objc func didSwitchMode(_ barButtonItem: UIBarButtonItem) {
    toggleMode()
  }
  
  func toggleMode() {
    mode = mode == .list ? .map : .list
    switchAppearanceModeBarButtonItem.image = UIImage(systemName: mode == .list ? "map" : "list.dash")
    switch mode {
    case .list:
      mapViewController.dismiss(animated: true, completion: nil)
    case .map:
      masterViewController.searchController.isActive = false
      mapViewController.modalPresentationStyle = .currentContext
      masterViewController.present(mapViewController, animated: true, completion: .none)
    }
  }

  func configureSearchNearMeButton() {
    searchNearMeButton.setImage(UIImage(systemName: "location.viewfinder"), for: .normal)
    searchInRegionButton.setTitle("Рядом со мной", for: .normal)
    searchInRegionButton.setTitleColor(.white, for: .normal)
    searchInRegionButton.translatesAutoresizingMaskIntoConstraints = false
    searchInRegionButton.backgroundColor = .systemTeal
    searchInRegionButton.layer.cornerRadius = 10
    searchInRegionButton.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
    searchInRegionButton.imageEdgeInsets = .init(top: 0, left: -10, bottom: 0, right: 0)
    searchInRegionButton.tintColor = .white
    searchInRegionButton.addTarget(self, action: #selector(didTapSearchInRegionButton), for: .touchUpInside)
  }

  
  func configureSearchInRegionButton() {
    searchInRegionButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
    searchInRegionButton.setTitle("Искать на этом участке", for: .normal)
    searchInRegionButton.setTitleColor(.white, for: .normal)
    searchInRegionButton.translatesAutoresizingMaskIntoConstraints = false
    searchInRegionButton.backgroundColor = .systemTeal
    searchInRegionButton.layer.cornerRadius = 10
    searchInRegionButton.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
    searchInRegionButton.imageEdgeInsets = .init(top: 0, left: -10, bottom: 0, right: 0)
    searchInRegionButton.tintColor = .white
    searchInRegionButton.addTarget(self, action: #selector(didTapSearchNearMeButon), for: .touchUpInside)
  }
  
}
