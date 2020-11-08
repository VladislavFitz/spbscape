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

final class MainSplitViewController: UISplitViewController {
  
  let masterViewController: MasterSearchViewController
  let mapViewController: BuldingHitsMapViewController
  let searchInRegionButton: UIButton
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.masterViewController = .init()
    self.mapViewController = .init()
    self.searchInRegionButton = UIButton()
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    try! masterViewController.hitsConnector.interactor.hitsInteractor(forSection: 0).connectController(mapViewController)
    viewControllers = [UINavigationController(rootViewController: masterViewController), mapViewController]
    masterViewController.hitsConnector.searcher.indexQueryStates[0].query.hitsPerPage = 1000
    mapViewController.didChangeVisibleRegion = { _ in
      self.searchInRegionButton.isHidden = false
    }
    mapViewController.view.addSubview(searchInRegionButton)
    activate(
      searchInRegionButton.centerXAnchor.constraint(equalTo: mapViewController.view.safeAreaLayoutGuide.centerXAnchor),
//      searchInRegionButton.trailingAnchor.constraint(equalTo: mapViewController.view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
      searchInRegionButton.bottomAnchor.constraint(equalTo: mapViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
    )
    configureSearchInRegionButton()
  }
  
  @objc func didTapSearchInRegionButton(_ sender: Any) {
    let searcher = masterViewController.hitsConnector.searcher
    let region = mapViewController.mapView.visibleMapRect
    searcher.indexQueryStates[0].query.insideBoundingBox = [BoundingBox(region)]
    searcher.search()
    searchInRegionButton.isHidden = true
  }
  
  func configureSearchInRegionButton() {
    searchInRegionButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
    searchInRegionButton.setTitle("Искать на этом участке", for: .normal)
    searchInRegionButton.setTitleColor(.white, for: .normal)
    searchInRegionButton.translatesAutoresizingMaskIntoConstraints = false
    searchInRegionButton.backgroundColor = .systemGreen
    searchInRegionButton.layer.cornerRadius = 10
    searchInRegionButton.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
    searchInRegionButton.imageEdgeInsets = .init(top: 0, left: -10, bottom: 0, right: 0)
    searchInRegionButton.tintColor = .white
    searchInRegionButton.addTarget(self, action: #selector(didTapSearchInRegionButton), for: .touchUpInside)
  }
  
}
