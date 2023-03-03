//
//  BuildingTableViewCell+Building.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 04.01.2022.
//  Copyright © 2022 Vladislav Fitc. All rights reserved.
//

import Foundation
import InstantSearchCore
import SpbscapeCore
import UIKit

extension BuildingTableViewCell {
  func configureWith(_ buildingHit: Hit<Building>) {
    let building = buildingHit.object
    buildingImageView.sd_setImage(with: building.photos.first?.url, placeholderImage: .placeholder)
    if case let .array(titles) = buildingHit.highlightResult?.value(forKey: "titles") {
      titleLabel.attributedText = NSAttributedString(highlightResult: titles.first!.value!,
                                                     attributes: [.foregroundColor: ColorScheme.primaryColor])
    } else {
      titleLabel.text = building.titles.first?.applyingTransform(.toLatin, reverse: false)
    }
    architectsLabel.text = "\("architects".localize()): " + building.architects.map(\.title).joined(separator: ", ")
    constructionYearsLabel.text = "\("yearsOfConstruction".localize()): " +
    building.constructionYears.map(\.description).joined(separator: ", ")
    stylesLabel.text = "\("styles".localize()): " + building.styles.map(\.title).joined(separator: ", ")
    if case let .array(addresses) = buildingHit.highlightResult?.value(forKey: "addresses"), !addresses.isEmpty {
      addressLabel.attributedText = addresses.compactMap { address in
        if case let .dictionary(addressDict) = address {
          let streetName = NSAttributedString(highlightResult: addressDict["streetName"]!.value!,
                                              attributes: [.foregroundColor: ColorScheme.primaryColor])
          let buildingIdentifier = NSAttributedString(highlightResult: addressDict["streetBuildingIdentifier"]!.value!,
                                                      attributes: [.foregroundColor: ColorScheme.primaryColor])
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
    case let .value(value):
      return value.value.taggedString.input
    case let .array(array):
      return offset + "[\(array.map { $0.description(withIdentation: identation + 1) }.joined(separator: ", "))]"
    case let .dictionary(dictionary):
      let content = dictionary.map { "\t\($0.key): \($0.value.description(withIdentation: identation + 1))" }
        .joined(separator: "\n")
      return offset + "[\n\(content)\n]"
    }
  }
}
