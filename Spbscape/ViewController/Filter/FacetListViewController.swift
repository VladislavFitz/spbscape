//
//  FacetListViewController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 04.01.2022.
//  Copyright © 2022 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearch

class FacetListViewController: UITableViewController, FacetListController {
  
  public var selectableItems: [SelectableItem<Facet>] = []
  
  var onClick: ((Facet) -> Void)?
  
  let cellID: String = "facetCellID"
  
  private let noResultsView = NoResultsView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundView = NoResultsView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
  }
  
  func setSelectableItems(selectableItems: [SelectableItem<Facet>]) {
    self.selectableItems = selectableItems
  }
  
  func reload() {
    if selectableItems.isEmpty {
      tableView.backgroundView = noResultsView
    } else {
      tableView.backgroundView = nil
    }
    tableView.reloadData()
  }
  
  open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return selectableItems.count
  }

  open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
    let selectableRefinement = selectableItems[indexPath.row]
    if let highlightedValue = selectableRefinement.item.highlighted.flatMap(HighlightedString.init) {
      cell.textLabel?.attributedText = NSAttributedString(highlightedString: highlightedValue, attributes: [.foregroundColor: ColorScheme.primaryColor])
    } else {
      cell.textLabel?.text = selectableRefinement.item.value
    }
    cell.accessoryType = selectableRefinement.isSelected ? .checkmark : .none

    return cell
  }
  
  open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectableItem = selectableItems[indexPath.row]
    self.onClick?(selectableItem.item)
  }
  
}
