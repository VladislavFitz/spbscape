//
//  BuldingHitsListViewController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 18/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore
import SpbscapeCore

class BuldingHitsListViewController: UITableViewController, HitsController {
  
  var hitsSource: HitsInteractor<Hit<Building>>?
    
  var didSelect: ((Building) -> Void)?
  
  private let noResultsView = NoResultsView()
    
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(BuildingTableViewCell.self, forCellReuseIdentifier: "buildingCell")
    tableView.rowHeight = 80
    tableView.backgroundColor = UIColor.clear
  }
  
  func reload() {
    if hitsSource?.numberOfHits() ?? 0 == 0 {
      tableView.backgroundView = noResultsView
    } else {
      tableView.backgroundView = nil
    }
    tableView.reloadData()
  }

  func highlight(_ building: Building) {
    guard let buildingIndex = hitsSource?.getCurrentHits().firstIndex(where: { $0.object.id == building.id }) else { return }
    let buildingIndexPath = IndexPath(row: buildingIndex, section: 0)
    tableView.selectRow(at: buildingIndexPath, animated: true, scrollPosition: .middle)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hitsSource?.numberOfHits() ?? 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "buildingCell", for: indexPath)
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard
      let buildingCell = cell as? BuildingTableViewCell,
      let building = hitsSource?.hit(atIndex: indexPath.row) else { return }
    buildingCell.configureWith(building)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let building = hitsSource?.hit(atIndex: indexPath.row) {
      didSelect?(building.object)
    }
  }
    
}
