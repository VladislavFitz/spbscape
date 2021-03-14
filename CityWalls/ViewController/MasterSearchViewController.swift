//
//  MasterSearchViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 08/11/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import InstantSearch
import CityWallsCore

class MasterSearchViewController: UIViewController {

  let searchBar: UISearchTextField
  let searchViewModel: SearchViewModel
  let hitsController: UIViewController
  
  lazy var toolbarContainer: ToolbarContainer = {
    let toolbar = UIToolbar()
    toolbar.items = toolbarItems
    return .init(toolbar: toolbar)
  }()
  
  let stackView = UIStackView()
  
  override var inputAccessoryView: UIView? {
    return UIDevice.current.userInterfaceIdiom == .phone ? toolbarContainer : nil
  }
      
  init(searchBar: UISearchTextField, hitsController: UIViewController, searchViewModel: SearchViewModel) {
    self.searchViewModel = searchViewModel
    self.searchBar = searchBar
    self.hitsController = hitsController
    super.init(nibName: nil, bundle: nil)
    
    searchBar.addTarget(self, action: #selector(searchBarEditingBegin), for: .editingDidBegin)
    searchBar.addTarget(self, action: #selector(searchBarEditingEnd), for: .editingDidEnd)

    NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: self, queue: .main) { _ in
      self.becomeFirstResponder()
    }
    searchBar.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
  }
    
  override var canBecomeFirstResponder: Bool {
    return true
  }
    
  @objc func searchBarEditingBegin() {
    if UIDevice.current.userInterfaceIdiom == .phone {
      searchBar.inputAccessoryView = toolbarContainer
    }
  }
  
  @objc func searchBarEditingEnd() {
    searchBar.inputAccessoryView = nil
    becomeFirstResponder()
  }
  
  
  @objc func didChangeText(_ textField: UISearchTextField) {
    let filtersFromTokens = Set(textField.tokens.compactMap { $0.representedObject as? Filter.Facet })
    searchViewModel.filterState
      .toFilterGroups()
      .flatMap(\.filters)
      .compactMap { $0 as? Filter.Facet }
      .filter { !filtersFromTokens.contains($0) }
      .forEach { searchViewModel.filterState.remove($0) }
    searchViewModel.filterState.notifyChange()
  }
  
  
  func searchInRect(_ mapRect: MKMapRect) {
    searchBar.removeTokensForBoundingBox()
    let boundingBox = BoundingBox(mapRect)
    let token = UISearchToken(boundingBox: boundingBox)
    searchBar.insertToken(token, at: 0)
    didChangeText(searchBar)
  }
    

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    addChild(hitsController)
    hitsController.didMove(toParent: self)
    super.viewDidLoad()
    
    view.backgroundColor = .white
    #if targetEnvironment(macCatalyst)
    view.backgroundColor = .clear
    #endif
    navigationItem.hidesSearchBarWhenScrolling = false
        
    searchBar.tokenBackgroundColor = .systemTeal
    searchViewModel.queryInputConnector.searcher.search()
    becomeFirstResponder()
        
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(stackView)
    activate(
      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    )
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    let searchBarContainer = UIView()
    searchBarContainer.translatesAutoresizingMaskIntoConstraints = false
    searchBarContainer.addSubview(searchBar)
    activate(
      searchBar.topAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.topAnchor, constant: 20),
      searchBar.bottomAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.bottomAnchor, constant: -5),
      searchBar.leadingAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.leadingAnchor, constant: 10),
      searchBar.trailingAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.trailingAnchor, constant: -10)
    )

    stackView.addArrangedSubview(searchBarContainer)
    stackView.addArrangedSubview(hitsController.view)

  }
  
}
