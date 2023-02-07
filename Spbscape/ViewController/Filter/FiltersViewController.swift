//
//  FiltersViewController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 07.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearch

class FiltersViewController: UIViewController {
  
  let searchController: UISearchController
  let queryInputController: TextFieldController
  let resultsViewController: SwitchContainerViewController
  let viewControllers: [FacetListViewController]
  
  lazy var clearFiltersBarButtonItem: UIBarButtonItem = {
    UIBarButtonItem(image: UIImage(systemName: "trash.circle"),
                                                style: .done,
                                                target: self,
                                                action: #selector(_clearFilters))
  }()
  
  let resultsCountBarButtonItem: UIBarButtonItem?
  
  var clearFilters: (() -> Void)?
  
  init(showResultsCount: Bool) {
    viewControllers = FilterSection.allCases.map { _ in FacetListViewController(style: .plain) }
    resultsViewController = SwitchContainerViewController(viewControllers: viewControllers)
    searchController = UISearchController(searchResultsController: nil)
    queryInputController = TextFieldController(searchBar: searchController.searchBar)
    resultsCountBarButtonItem = showResultsCount ? UIBarButtonItem() : nil
    super.init(nibName: nil, bundle: nil)
    navigationItem.searchController = searchController
    let closeBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle"),
                                             style: .done,
                                             target: self,
                                             action: #selector(dismissViewController))
    
    let additionalBarButtonItems: [UIBarButtonItem] = resultsCountBarButtonItem.flatMap {
      [
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                        target: nil,
                        action: nil),
        $0
      ]
    } ?? []
    
    toolbarItems =
    [clearFiltersBarButtonItem] +
    additionalBarButtonItems + [
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      closeBarButtonItem
    ]
    addChild(resultsViewController)
    resultsViewController.didMove(toParent: self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "filters".localize()
    view.backgroundColor = .systemBackground
    navigationController?.isToolbarHidden = false
    setupSearchController()
    view.addSubview(resultsViewController.view)
    resultsViewController.view.pin(to: view)
  }
  
  @objc private func dismissViewController() {
    navigationController?.dismiss(animated: true, completion: nil)
  }
  
  @objc private func _clearFilters() {
    clearFilters?()
  }
  
  private func setupSearchController() {
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.searchBar.showsScopeBar = true
    searchController.isActive = true
    searchController.searchBar.showsCancelButton = false
    searchController.searchBar.scopeButtonTitles = FilterSection.allCases.map(\.title)
    searchController.searchBar.delegate = self
  }
  
}

extension FiltersViewController: UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    resultsViewController.setVisibleViewController(atIndex: selectedScope)
  }
  
}

