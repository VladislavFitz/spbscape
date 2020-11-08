//
//  BuldingHitsListViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 18/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearch
import CityWallsCore

class BuldingHitsListViewController: UITableViewController, HitsController {
  
  var hitsSource: HitsInteractor<Building>?
  
  var didSelect: ((Building) -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(BuildingTableViewCell.self, forCellReuseIdentifier: "buildingCell")
    tableView.rowHeight = 130
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
      didSelect?(building)
    }
  }
    
}
