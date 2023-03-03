//
//  UISearchToken+Convenience.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 18/01/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import InstantSearchCore
import SpbscapeCore
import UIKit

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
