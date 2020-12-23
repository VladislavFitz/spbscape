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
  
  let queryInputConnector: QueryInputConnector
  let queryInputController: TextFieldController

  let searchController: UISearchController
  let hitsConnector: MultiIndexHitsConnector
  
  let filterState: FilterState

  let buildingHitsController: BuldingHitsListViewController
  
  let hitsCountBarButtonItem: UIBarButtonItem
    
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    let buildingHitsInteractor = HitsInteractor<Building>()
    
    buildingHitsController = .init()
    
    filterState = .init()
    
    hitsConnector = .init(appID: .cityWallsAppID, apiKey: .cityWallsApiKey, indexModules: [
      .init(indexName: .buildings, hitsInteractor: buildingHitsInteractor, filterState: filterState),
    ])
    
    hitsConnector.searcher.connectFilterState(filterState, withQueryAtIndex: 0)
    
    searchController = UISearchController(searchResultsController: nil)
    queryInputController = .init(searchBar: searchController.searchBar)
    queryInputConnector = .init(searcher: hitsConnector.searcher, controller: queryInputController)
    hitsCountBarButtonItem = .init(title: "Результатов: 0", style: .done, target: nil, action: nil)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    buildingHitsController.view.translatesAutoresizingMaskIntoConstraints = false
    
    buildingHitsInteractor.connectController(buildingHitsController)

    
    searchController.searchBar.searchTextField.delegate = self
    
//    buildingHitsController.mapHitsViewController.didChangeVisibleRegion = { region in
//      let searcher = self.hitsConnector.searcher
//      searcher.indexQueryStates[0].query.insideBoundingBox = [BoundingBox(region)]
//      searcher.search()
//    }
        
    filterState.onChange.subscribe(with: self) { controller, container in
      let searchTextField = controller.searchController.searchBar.searchTextField
      searchTextField.tokens.removeAll()
      container
        .toFilterGroups()
        .flatMap(\.filters)
        .compactMap(UISearchToken.init)
        .forEach { searchTextField.insertToken($0, at: 0) }
    }
    
    
    searchController.searchBar.searchTextField.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
  }
  
  
  @objc func didTap() {
    let filterViewController = FilterViewController(filterState: filterState)
    let navigationController = UINavigationController(rootViewController: filterViewController)
    hitsConnector.searcher.onResults.subscribePast(with: filterViewController) { (filterViewController, responses) in
      guard let firstResponseStats = responses.results.first?.searchStats else {
        return
      }
      filterViewController.hitsCountBarButtonItem.title = "Результатов: \(firstResponseStats.totalHitsCount)"
    }.onQueue(.main)
    present(navigationController, animated: true, completion: nil)
  }
  
  @objc func didChangeText(_ textField: UISearchTextField) {
    let searcher = hitsConnector.searcher
    let boundingBoxes = textField.tokens.compactMap { $0.representedObject as? BoundingBox }
    searcher.indexQueryStates[0].query.insideBoundingBox = boundingBoxes.isEmpty ? nil : boundingBoxes
    
    let filtersFromTokens = Set(textField.tokens.compactMap { $0.representedObject as? Filter.Facet })
    filterState
      .toFilterGroups()
      .flatMap(\.filters)
      .compactMap { $0 as? Filter.Facet }
      .filter { !filtersFromTokens.contains($0) }
      .forEach { filterState.remove($0) }
    filterState.notifyChange()
  }
  
  
  func searchInRect(_ mapRect: MKMapRect) {
    let searchTextField = searchController.searchBar.searchTextField
    searchTextField.removeTokensForBoundingBox()
    let boundingBox = BoundingBox(mapRect)
    let token = UISearchToken(boundingBox: boundingBox)
    searchTextField.insertToken(token, at: 0)
    didChangeText(searchTextField)
  }
    

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Санкт-Петербург"
    view.backgroundColor = .white
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.obscuresBackgroundDuringPresentation = false
    navigationItem.hidesSearchBarWhenScrolling = false
    navigationItem.searchController = searchController
    navigationController?.isToolbarHidden = false
    let filterBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(didTap))
    toolbarItems = [
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      hitsCountBarButtonItem,
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      filterBarButtonItem
    ]
  
    hitsConnector.searcher.onResults.subscribe(with: self) { (vc, responses) in
      guard let firstResponseStats = responses.results.first?.searchStats else {
        return
      }
      vc.hitsCountBarButtonItem.title = "Результатов: \(firstResponseStats.totalHitsCount)"
    }.onQueue(.main)
        
    searchController.searchBar.searchTextField.tokenBackgroundColor = .systemTeal
    addChild(buildingHitsController)
    buildingHitsController.didMove(toParent: self)
    view.addSubview(buildingHitsController.view)
    activate(
      buildingHitsController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      buildingHitsController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      buildingHitsController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      buildingHitsController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
    )
    queryInputConnector.searcher.search()
  }
        
}

extension UISearchTextField {
    
  func removeTokensForFilter(withAttribute attribute: Attribute) {
    tokens
      .enumerated()
      .filter { ($0.element.representedObject as? FilterType)?.attribute == attribute }
      .map { $0.offset }
      .forEach(removeToken(at:))
  }
  
  func removeTokensForBoundingBox() {
    tokens
      .enumerated()
      .filter { $1.representedObject is BoundingBox }
      .map { $0.0 }
      .forEach(removeToken(at:))
  }
  
}

extension UISearchToken {
  
  convenience init?(filter: FilterType) {
    if let facetFilter = filter as? Filter.Facet {
      self.init(facetFilter: facetFilter)
    } else {
      return nil
    }
  }
  
  convenience init?(facetFilter: Filter.Facet) {
    switch facetFilter.attribute {
    case "addresses.streetName":
      self.init(icon: UIImage(systemName: "mappin.circle"), text: facetFilter.value.description)
    case "architects.title":
      self.init(icon: UIImage(systemName: "person.circle"), text: facetFilter.value.description)
    case "styles.title":
      self.init(icon: UIImage(systemName: "building.columns"), text: facetFilter.value.description)
    default:
      return nil
    }
    representedObject = facetFilter
  }
  
  convenience init(architect: Architect) {
    self.init(icon: UIImage(systemName: "person.circle"), text: architect.name)
    representedObject = Filter.Facet(attribute: "architects.id", stringValue: "\(architect.id)")
  }
  
  convenience init(style: Style) {
    self.init(icon: UIImage(systemName: "building.columns"), text: style.name)
    representedObject = Filter.Facet(attribute: "styles.id", stringValue: "\(style.id)")
  }

  convenience init(street: Street) {
    self.init(icon: UIImage(systemName: "mappin.circle"), text: street.title)
    representedObject = Filter.Facet(attribute: "addresses.id", stringValue: "\(street.id)")
  }
  
  convenience init(boundingBox: BoundingBox) {
    self.init(icon: UIImage(systemName: "rectangle.dashed"), text: "Участок карты")
    representedObject = boundingBox
  }
  
}

extension MasterSearchViewController: UISearchTextFieldDelegate {
  
  
  
}
