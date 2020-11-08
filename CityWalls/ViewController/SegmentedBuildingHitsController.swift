//
//  SegmentedBuildingHitsController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 18/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearch
import CityWallsCore

class SegmentedBuildingHitsController: UIViewController, HitsController {
  
  static var initialMode: Mode = .map
  
  var hitsSource: HitsInteractor<Building>? {
    didSet {
      listHitsViewController.hitsSource = hitsSource
      mapHitsViewController.hitsSource = hitsSource
      reload()
    }
  }
  
  enum Mode {
    case map, list
  }
  
  let listHitsViewController: BuldingHitsListViewController
  let mapHitsViewController: BuldingHitsMapViewController
  let switchModeControl: UISegmentedControl

  var didSelect: ((Building) -> Void)? {
    didSet {
      listHitsViewController.didSelect = didSelect
      mapHitsViewController.didSelect = didSelect
    }
  }
  
  var mode: Mode {
    didSet {
      listHitsViewController.view.isHidden = mode == .map
      mapHitsViewController.view.isHidden = mode == .list
      switchModeControl.selectedSegmentIndex = mode == .map ? 0 : 1
    }
  }
  
  
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.listHitsViewController = .init()
    self.mapHitsViewController = .init()
    self.switchModeControl = .init()
    self.mode = .map
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    addChilds()
    mode = SegmentedBuildingHitsController.initialMode
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayout()
    configureSegmentedControl()
  }
  
  private func configureSegmentedControl() {
    switchModeControl.insertSegment(with: UIImage(systemName: "map"), at: 0, animated: false)
    switchModeControl.insertSegment(with: UIImage(systemName: "list.bullet"), at: 1, animated: false)
    switchModeControl.selectedSegmentIndex = 0
    switchModeControl.translatesAutoresizingMaskIntoConstraints = false
    switchModeControl.addTarget(self, action: #selector(didSwitchSegment), for: .valueChanged)
  }
  
  @objc func didSwitchSegment() {
    switch switchModeControl.selectedSegmentIndex {
    case 0:
      mode = .map
    case 1:
      mode = .list
    default:
      break
    }
  }
  
  func addChilds() {
    addChild(mapHitsViewController)
    mapHitsViewController.didMove(toParent: self)
    addChild(listHitsViewController)
    listHitsViewController.didMove(toParent: self)
  }
  
  func setupLayout() {
    let mapView = mapHitsViewController.view!
    let listView = listHitsViewController.view!
    [
      mapView,
      listView,
      switchModeControl
    ].forEach { $0?.translatesAutoresizingMaskIntoConstraints = false }
    view.addSubview(listView)
    view.addSubview(mapView)
    view.addSubview(switchModeControl)
    activate(
      mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      listView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      listView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      listView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      listView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      switchModeControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      switchModeControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    )
  }
  
  func scrollToTop() {
    listHitsViewController.scrollToTop()
  }
    
  func reload() {
    listHitsViewController.reload()
    mapHitsViewController.reload()
  }
  
}
