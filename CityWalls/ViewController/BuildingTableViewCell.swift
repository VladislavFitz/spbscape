//
//  BuildingTableViewCell.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 18/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import CityWallsCore

class BuildingTableViewCell: UITableViewCell {
  
  let buildingImageView: UIImageView
  let titleLabel: UILabel
  let architectsLabel: UILabel
  let constructionYearsLabel: UILabel
  let stylesLabel: UILabel
  let addressLabel: UILabel
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    buildingImageView = .init()
    titleLabel = .init()
    architectsLabel = .init()
    constructionYearsLabel = .init()
    stylesLabel = .init()
    addressLabel = .init()
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    let backgroundColor = selected ? UIColor.systemTeal.withAlphaComponent(0.2) : .clear
    contentView.backgroundColor = backgroundColor
  }
  
  func setupLayout() {
    let mainStackView = UIStackView()
    let imageStackView = UIStackView()
    let infoStackView = UIStackView()
    [
     buildingImageView,
     titleLabel,
     architectsLabel,
     constructionYearsLabel,
     stylesLabel,
     addressLabel,
     mainStackView,
     imageStackView,
     infoStackView
    ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    mainStackView.axis = .horizontal
    mainStackView.spacing = 10
    contentView.addSubview(mainStackView)
    activate(
      mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
      mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
      mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
      mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
    )
    mainStackView.addArrangedSubview(imageStackView)
    imageStackView.axis = .vertical
    let phView = UIView()
    phView.translatesAutoresizingMaskIntoConstraints = false
    imageStackView.addArrangedSubview(buildingImageView)
    imageStackView.addArrangedSubview(phView)
    
    mainStackView.addArrangedSubview(infoStackView)
    infoStackView.axis = .vertical
    infoStackView.spacing = 5
    infoStackView.addArrangedSubview(titleLabel)
    infoStackView.addArrangedSubview(architectsLabel)
    infoStackView.addArrangedSubview(constructionYearsLabel)
    infoStackView.addArrangedSubview(stylesLabel)
    infoStackView.addArrangedSubview(addressLabel)
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    infoStackView.addArrangedSubview(view)
    buildingImageView.contentMode = .scaleAspectFit
    buildingImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.33).isActive = true
    
    titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
    [architectsLabel, constructionYearsLabel, stylesLabel, addressLabel].forEach { $0.font = . systemFont(ofSize: 12, weight: .light)}
  }
  
}

extension BuildingTableViewCell {
  
  func configureWith(_ building: Building) {
    buildingImageView.sd_setImage(with: building.photos.first?.url)
    titleLabel.text = building.titles.first
    architectsLabel.text = "Архитекторы: " + building.architects.map(\.title).joined(separator: ", ")
    constructionYearsLabel.text = "Годы постройки: " + building.constructionYears.map(\.description).joined(separator: ", ")
    stylesLabel.text = "Стили: " + building.styles.map(\.title).joined(separator: ", ")
    addressLabel.text = "Адрес: " + building.addresses.map(\.description).joined(separator: ", ")

  }
  
}
