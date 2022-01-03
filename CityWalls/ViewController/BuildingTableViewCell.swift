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
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    backgroundView = UIView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    let backgroundColor = selected ? ColorScheme.tintColor.withAlphaComponent(0.2) : .clear
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
//    infoStackView.addArrangedSubview(architectsLabel)
//    infoStackView.addArrangedSubview(constructionYearsLabel)
//    infoStackView.addArrangedSubview(stylesLabel)
    infoStackView.addArrangedSubview(addressLabel)
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    infoStackView.addArrangedSubview(view)
    buildingImageView.layer.cornerRadius = 10
    buildingImageView.contentMode = .scaleAspectFill
    buildingImageView.clipsToBounds = true
    buildingImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2).isActive = true
    
    titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
    titleLabel.numberOfLines = 0
    [architectsLabel, constructionYearsLabel, stylesLabel, addressLabel].forEach { $0.font = . systemFont(ofSize: 12, weight: .light)}
  }
  
}
