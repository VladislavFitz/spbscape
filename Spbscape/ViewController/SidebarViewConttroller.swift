//
//  SidebarViewConttroller.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 08/11/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import InstantSearchCore
import SpbscapeCore

class SidebarViewConttroller: UIViewController {
  
  let searchBar: UISearchTextField
  //  var searchBar: UISearchTextField {
  //    searchController.searchBar.searchTextField
  //  }
  //  let searchController: UISearchController
  //  let searchBarContainer: UIView
  let contentController: UIViewController
  
  lazy var toolbarContainer: ToolbarContainer = {
    let toolbar = UIToolbar()
    //    toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    //    toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .compact)
    
    return .init(toolbar: toolbar)
  }()
  
  //  override var inputAccessoryView: UIView? {
  //    return UIDevice.current.userInterfaceIdiom == .phone ? toolbarContainer : nil
  //  }
  
  init(contentController: UIViewController) {
    self.searchBar = .init()
    //    self.searchBarContainer = .init()
    self.contentController = contentController
    //    self.searchController = .init(searchResultsController: contentController)
    super.init(nibName: nil, bundle: nil)
  }
  
  //  override var canBecomeFirstResponder: Bool {
  //    return true
  //  }
  
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
    navigationController?.isToolbarHidden = false
    //    if UIDevice.current.userInterfaceIdiom == .phone {
    //      searchController.searchBar.inputAccessoryView = toolbarContainer
    //    }
    //    searchController.delegate = self
    //    searchController.hidesNavigationBarDuringPresentation = false
    //    searchController.showsSearchResultsController = true
    //    searchController.automaticallyShowsCancelButton = false
    //    navigationItem.searchController = searchController
    
    //    navigationController?.isNavigationBarHidden = true
    
#if targetEnvironment(macCatalyst)
    view.backgroundColor = .clear
#else
    title = "Saint-Petersburg"
    view.backgroundColor = .systemBackground
#endif
    
    searchBar.tokenBackgroundColor = ColorScheme.tintColor
    //    searchBar.translatesAutoresizingMaskIntoConstraints = false
    
    //    searchBarContainer.addSubview(searchBar)
    //    searchBarContainer.translatesAutoresizingMaskIntoConstraints = false
    
    //    activate(
    //      searchBar.topAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.topAnchor, constant: 7),
    //      searchBar.bottomAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.bottomAnchor, constant: -7),
    //      searchBar.leadingAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.leadingAnchor, constant: 10),
    //      searchBar.trailingAnchor.constraint(equalTo: searchBarContainer.safeAreaLayoutGuide.trailingAnchor, constant: -10)
    //    )
    
    //    contentController.view.translatesAutoresizingMaskIntoConstraints = false
    
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
      break
      //      searchBarContainer.backgroundColor = .systemBackground
      //      view.addSubview(contentController.view)
      //      activate(
      //        contentController.view.topAnchor.constraint(equalTo: view.topAnchor),
      //        contentController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      //        contentController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      //        contentController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
      //      )
      
      //      view.addSubview(searchBarContainer)
      //      activate(
      //        searchBarContainer.topAnchor.constraint(equalTo: view.topAnchor),
      //        searchBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      //        searchBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
      //      )
      
    default:
      break
      //      let stackView = UIStackView()
      //      stackView.axis = .vertical
      //      stackView.translatesAutoresizingMaskIntoConstraints = false
      
      //      view.addSubview(stackView)
      //      activate(
      //        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      //        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      //        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      //        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
      //      )
      //      stackView.addArrangedSubview(searchBarContainer)
      //      stackView.addArrangedSubview(contentController.view)
    }
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    //    searchController.isActive = true
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    //    contentController.additionalSafeAreaInsets = .init(top: searchBarContainer.frame.height - view.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
  }
  
}

extension SidebarViewConttroller: UISearchControllerDelegate {
  
  func willPresentSearchController(_ searchController: UISearchController) {
    
  }
  
  func willDismissSearchController(_ searchController: UISearchController) {
    
  }
  
}