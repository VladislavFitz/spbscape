//
//  BuildingViewModel.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 14.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import SpbscapeCore

class BuildingViewModel: ObservableObject {
  
  let title: String
  let images: [URL]
  let address: String
  let architects: String
  let constructionYears: String
  let style: String
  let citywallsID: String
  
  @Published var showImageViewer: Bool = false
  @Published var selectedImageURL: URL = URL(string: "www.a.com")!
  
  init(title: String,
       images: [URL],
       address: String,
       architects: String,
       constructionYears: String,
       style: String,
       citywallsID: String) {
    self.title = title
    self.images = images
    self.address = address
    self.architects = architects
    self.constructionYears = constructionYears
    self.style = style
    self.citywallsID = citywallsID
  }
  
  convenience init(building: Building) {
    self.init(title: building.titles.joined(separator: ", "),
              images: building.photos.map(\.url),
              address: building.addresses.map(\.description).joined(separator: "\n"),
              architects: building.architects.map(\.title).joined(separator: "\n"),
              constructionYears: building.constructionYears.map(\.description).joined(separator: "\n"),
              style: building.styles.map(\.title).joined(separator: "\n"),
              citywallsID: "\(building.id)")
  }
  
  func content() -> [(key: String, value: String)] {
    [
      ("address", address),
      ("architects", architects),
      ("yearsOfConstruction", constructionYears),
      ("style", style),
    ]
  }
  
}
