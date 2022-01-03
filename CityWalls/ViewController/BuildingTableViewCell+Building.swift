//
//  BuildingTableViewCell+Building.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 04.01.2022.
//  Copyright © 2022 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore
import CityWallsCore

extension BuildingTableViewCell {
  
  func configureWith(_ building: Building) {
    buildingImageView.sd_setImage(with: building.photos.first?.url)
    titleLabel.text = building.titles.first
    architectsLabel.text = "Архитекторы: " + building.architects.map(\.title).joined(separator: ", ")
    constructionYearsLabel.text = "Годы постройки: " + building.constructionYears.map(\.description).joined(separator: ", ")
    stylesLabel.text = "Стили: " + building.styles.map(\.title).joined(separator: ", ")
    addressLabel.text = /*"Адрес: " +*/ building.addresses.map(\.description).joined(separator: ", ")
  }
  
  func configureWith(_ buildingHit: Hit<Building>) {
    let building = buildingHit.object
    buildingImageView.sd_setImage(with: building.photos.first?.url)
    if case .array(let titles) = buildingHit.highlightResult?.value(forKey: "titles") {
      titleLabel.attributedText = NSAttributedString(highlightResult: titles.first!.value!, attributes: [.foregroundColor: ColorScheme.tintColor])
    } else {
      titleLabel.text = building.titles.first
    }
    architectsLabel.text = "Архитекторы: " + building.architects.map(\.title).joined(separator: ", ")
    constructionYearsLabel.text = "Годы постройки: " + building.constructionYears.map(\.description).joined(separator: ", ")
    stylesLabel.text = "Стили: " + building.styles.map(\.title).joined(separator: ", ")
    if case .array(let addresses) = buildingHit.highlightResult?.value(forKey: "addresses"), !addresses.isEmpty {
      addressLabel.attributedText = addresses.compactMap { address in
        if case .dictionary(let addressDict) = address {
          let streetName = NSAttributedString(highlightResult: addressDict["streetName"]!.value!, attributes: [.foregroundColor: ColorScheme.tintColor])
          let buildingIdentifier = NSAttributedString(highlightResult: addressDict["streetBuildingIdentifier"]!.value!, attributes: [.foregroundColor: ColorScheme.tintColor])
          let addressString = NSMutableAttributedString()
          addressString.append(streetName)
          addressString.append(NSAttributedString(string: ", "))
          addressString.append(buildingIdentifier)
          return addressString
        } else {
          return nil
        }
      }.reduce(NSMutableAttributedString()) { (output, value: NSAttributedString) in
        output.append(value)
        output.append(NSAttributedString(string: ", "))
        return output
      }
    } else {
      addressLabel.text = building.addresses.map(\.description).joined(separator: ", ")
    }

  }
  
}

extension TreeModel: CustomStringConvertible where T == HighlightResult {
  
  public var description: String {
    return description(withIdentation: 0)
  }
  
  func description(withIdentation identation: Int = 0) -> String {
    let offset = Array(repeating: "\t", count: identation).joined()
    switch self {
    case .value(let value):
      return value.value.taggedString.input
    case .array(let array):
      return offset + "[\(array.map { $0.description(withIdentation: identation + 1) }.joined(separator: ", "))]"
    case .dictionary(let dictionary):
      return offset + "[\n\(dictionary.map { "\t\($0.key): \($0.value.description(withIdentation: identation + 1))" }.joined(separator: "\n"))\n]"
    }
  }
  
  
}
