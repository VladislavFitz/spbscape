//
//  BuildingAttributeHitsViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 18/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearch

class BuildingAttributeHitsViewController<Attribute: Codable & CustomStringConvertible>: UITableViewController, HitsController {
  
  var hitsSource: HitsInteractor<Attribute>?
  
  var didSelect: ((Attribute) -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "attribute")
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hitsSource?.numberOfHits() ?? 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "attribute", for: indexPath)
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.textLabel?.text = hitsSource?.hit(atIndex: indexPath.row)?.description
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let attribute = hitsSource?.hit(atIndex: indexPath.row) {
      didSelect?(attribute)
    }
  }

}
