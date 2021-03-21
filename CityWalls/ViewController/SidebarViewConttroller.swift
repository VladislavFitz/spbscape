//
//  SidebarViewConttroller.swift
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

class SidebarViewConttroller: UIViewController {

  let searchBar: UISearchTextField
  let hitsController: UIViewController
  
  #if targetEnvironment(macCatalyst)
  let searchBarContainer = UIView()
  #else
  let searchBarContainer = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
  #endif

  
  lazy var toolbarContainer: ToolbarContainer = {
    let toolbar = UIToolbar()
    toolbar.items = toolbarItems
    return .init(toolbar: toolbar)
  }()
  
  let stackView = UIStackView()
  
  override var inputAccessoryView: UIView? {
    return UIDevice.current.userInterfaceIdiom == .phone ? toolbarContainer : nil
  }
      
  init(hitsController: UIViewController) {
    self.searchBar = .init()
    self.hitsController = hitsController
    super.init(nibName: nil, bundle: nil)
    
//    searchBar.addTarget(self, action: #selector(searchBarEditingBegin), for: .editingDidBegin)
//    searchBar.addTarget(self, action: #selector(searchBarEditingEnd), for: .editingDidEnd)

//    NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: self, queue: .main) { _ in
//      self.becomeFirstResponder()
//    }
  }
    
  override var canBecomeFirstResponder: Bool {
    return true
  }
    
  @objc func searchBarEditingBegin() {
//    if UIDevice.current.userInterfaceIdiom == .phone {
//      searchBar.inputAccessoryView = toolbarContainer
//    }
  }
  
  @objc func searchBarEditingEnd() {
//    if UIDevice.current.userInterfaceIdiom == .phone {
//      searchBar.inputAccessoryView = nil
//    }
//    becomeFirstResponder()
  }
  
  func searchInRect(_ mapRect: MKMapRect) {
    searchBar.removeTokensForBoundingBox()
    let boundingBox = BoundingBox(mapRect)
    let token = UISearchToken(boundingBox: boundingBox)
    searchBar.insertToken(token, at: 0)
    searchBar.sendActions(for: .editingChanged)
  }
    

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    addChild(hitsController)
    hitsController.didMove(toParent: self)
    super.viewDidLoad()
    navigationController?.isNavigationBarHidden = true
    #if targetEnvironment(macCatalyst)
    view.backgroundColor = .clear
    #else
    view.backgroundColor = .systemBackground
    #endif
    navigationItem.hidesSearchBarWhenScrolling = false
        
    searchBar.tokenBackgroundColor = ColorScheme.tintColor
    becomeFirstResponder()
        
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
//    view.addSubview(stackView)
//    activate(
//      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//      stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//    )
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    
    #if targetEnvironment(macCatalyst)
    searchBarContainer.addSubview(searchBar)
    #else
    searchBarContainer.contentView.addSubview(searchBar)
    #endif

    searchBarContainer.translatesAutoresizingMaskIntoConstraints = false
    
    activate(
      searchBar.topAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.topAnchor, constant: 10),
      searchBar.bottomAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.bottomAnchor, constant: -10),
      searchBar.leadingAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.leadingAnchor, constant: 10),
      searchBar.trailingAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.trailingAnchor, constant: -10)
    )
//    stackView.addArrangedSubview(searchBarContainer)
//    stackView.addArrangedSubview(hitsController.view)
    
    view.addSubview(hitsController.view)
    hitsController.view.translatesAutoresizingMaskIntoConstraints = false
//    hitsController.view.safeArea
    

    
    view.addSubview(searchBarContainer)
    activate(
      searchBarContainer.topAnchor.constraint(equalTo: view.topAnchor),
      searchBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      searchBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    )
    
    
    activate(
      hitsController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hitsController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      hitsController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hitsController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    )
  
  }
    
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    hitsController.additionalSafeAreaInsets = .init(top: searchBarContainer.frame.height - view.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
  }
  
//  override func viewWillDisappear(_ animated: Bool) {
//    super.viewWillDisappear(animated)
//    toolbarContainer.isHidden = true
//  }
//
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//    toolbarContainer.isHidden = false
//  }
  
  
  
}
