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
  let searchBarContainer: UIView
  let contentController: UIViewController
  
  lazy var toolbarContainer: ToolbarContainer = {
    let toolbar = UIToolbar()
    toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .compact)
    toolbar.items = toolbarItems
    return .init(toolbar: toolbar)
  }()
    
  override var inputAccessoryView: UIView? {
    return UIDevice.current.userInterfaceIdiom == .phone ? toolbarContainer : nil
  }
      
  init(contentController: UIViewController) {
    self.searchBar = .init()
    self.searchBarContainer = .init()
    self.contentController = contentController
    super.init(nibName: nil, bundle: nil)
  }
    
  override var canBecomeFirstResponder: Bool {
    return true
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
    addChild(contentController)
    contentController.didMove(toParent: self)
    super.viewDidLoad()
    
    navigationController?.isNavigationBarHidden = true
    
    #if targetEnvironment(macCatalyst)
    view.backgroundColor = .clear
    #else
    view.backgroundColor = .systemBackground
    #endif
        
    searchBar.tokenBackgroundColor = ColorScheme.tintColor
    searchBar.translatesAutoresizingMaskIntoConstraints = false
        
    searchBarContainer.addSubview(searchBar)
    searchBarContainer.translatesAutoresizingMaskIntoConstraints = false
    
    activate(
      searchBar.topAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.topAnchor, constant: 7),
      searchBar.bottomAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.bottomAnchor, constant: -7),
      searchBar.leadingAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.leadingAnchor, constant: 10),
      searchBar.trailingAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.trailingAnchor, constant: -10)
    )

    contentController.view.translatesAutoresizingMaskIntoConstraints = false
    
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
      view.addSubview(contentController.view)
      activate(
        contentController.view.topAnchor.constraint(equalTo: view.topAnchor),
        contentController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        contentController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        contentController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
      )
      
      view.addSubview(searchBarContainer)
      activate(
        searchBarContainer.topAnchor.constraint(equalTo: view.topAnchor),
        searchBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        searchBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
      )
      
    default:
      let stackView = UIStackView()
      stackView.axis = .vertical
      stackView.translatesAutoresizingMaskIntoConstraints = false
      
      view.addSubview(stackView)
      activate(
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
      )
      stackView.addArrangedSubview(searchBarContainer)
      stackView.addArrangedSubview(contentController.view)
    }
    
  }
    
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    contentController.additionalSafeAreaInsets = .init(top: searchBarContainer.frame.height - view.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
  }
    
}
