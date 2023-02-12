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

final class FiltersViewController: UIViewController {
  
  private let searchController: UISearchController
  private let resultsViewController: SwitchContainerViewController

  let queryInputController: TextFieldController
  let viewControllers: [FacetListViewController]
  
  private let resultsCountViewModel: ResultsCountViewModel?
  private let filtersStateViewModel: FiltersStateViewModel
  private var resultsCountBarButtonItem: UIBarButtonItem?
  private var clearFiltersBarButtonItem: UIBarButtonItem?
    
  init(filtersStateViewModel: FiltersStateViewModel,
       resultsCountViewModel: ResultsCountViewModel?) {
    self.filtersStateViewModel = filtersStateViewModel
    self.resultsCountViewModel = resultsCountViewModel
    viewControllers = FilterSection.allCases.map { _ in FacetListViewController(style: .plain) }
    resultsViewController = SwitchContainerViewController(viewControllers: viewControllers)
    searchController = UISearchController(searchResultsController: nil)
    queryInputController = TextFieldController(searchBar: searchController.searchBar)
    clearFiltersBarButtonItem = nil
    resultsCountBarButtonItem = nil
    super.init(nibName: nil, bundle: nil)
    navigationItem.searchController = searchController
    resultsCountViewModel?.addObserver(self)
    filtersStateViewModel.addObserver(self)
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
    setupResultsViewController()
    setupToolbar()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    searchController.isActive = false
  }
  
  @objc private func dismissViewController() {
    navigationController?.dismiss(animated: true, completion: nil)
  }
  
  @objc private func clearFilters() {
    filtersStateViewModel.clearFilters()
  }
  
  deinit {
    resultsCountViewModel?.removeObserver(self)
    filtersStateViewModel.removeObserver(self)
  }
  
}

private extension FiltersViewController {
  
  func setupToolbar() {
    let closeBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle"),
                                             style: .done,
                                             target: self,
                                             action: #selector(dismissViewController))
    let clearFiltersBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash.circle"),
                                                    style: .done,
                                                    target: self,
                                                    action: #selector(clearFilters))
    self.clearFiltersBarButtonItem = clearFiltersBarButtonItem
    clearFiltersBarButtonItem.isEnabled = !filtersStateViewModel.areFiltersEmpty
    
    var toolbarItems: [UIBarButtonItem] = []
    toolbarItems.append(clearFiltersBarButtonItem)
    
    if let resultsCountViewModel {
      let resultsCountBarButtonItem = UIBarButtonItem()
      self.resultsCountBarButtonItem = resultsCountBarButtonItem
      resultsCountBarButtonItem.title = resultsCountViewModel.resultsCountTitle()
      toolbarItems.append(.flexibleSpace)
      toolbarItems.append(resultsCountBarButtonItem)
    }
    toolbarItems.append(.flexibleSpace)
    toolbarItems.append(closeBarButtonItem)
    
    self.toolbarItems = toolbarItems
  }
  
  func setupResultsViewController() {
    addChild(resultsViewController)
    resultsViewController.didMove(toParent: self)
    view.addSubview(resultsViewController.view)
    resultsViewController.view.pin(to: view)
  }
  
  func setupSearchController() {
    searchController.isActive = true
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.searchBar.showsScopeBar = true
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

extension FiltersViewController: ResultsCountObserver {
  
  func setResultsCount(_ resultsCount: String) {
    if let resultsCountBarButtonItem, let resultsCountViewModel {
      resultsCountBarButtonItem.title = resultsCountViewModel.resultsCountTitle()
    }
  }
  
}

extension FiltersViewController: FiltersStateObserver {
  
  func setFiltersEmpty(_ empty: Bool) {
    clearFiltersBarButtonItem?.isEnabled = !empty
  }
  
}
