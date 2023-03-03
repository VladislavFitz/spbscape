//
//  BuildingTableViewCell.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 18/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import SDWebImage
import SpbscapeCore
import UIKit

class BuildingTableViewCell: UITableViewCell {
  let buildingImageView: UIImageView
  let titleLabel: UILabel
  let architectsLabel: UILabel
  let constructionYearsLabel: UILabel
  let stylesLabel: UILabel
  let addressLabel: UILabel

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    buildingImageView = .init(autolayout: ())
    titleLabel = .init(autolayout: ())
    architectsLabel = .init(autolayout: ())
    constructionYearsLabel = .init(autolayout: ())
    stylesLabel = .init(autolayout: ())
    addressLabel = .init(autolayout: ())
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayout()
    buildingImageView.sd_imageIndicator = SDWebImageActivityIndicator.large
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    backgroundView = UIView()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func setSelected(_ selected: Bool, animated _: Bool) {
    let backgroundColor = selected ? ColorScheme.primaryColor.withAlphaComponent(0.2) : .clear
    contentView.backgroundColor = backgroundColor
  }

  func setupLayout() {
    let mainStackView = UIStackView(autolayout: ())
    let imageStackView = UIStackView(autolayout: ())
    let infoStackView = UIStackView(autolayout: ())
    mainStackView.axis = .horizontal
    mainStackView.spacing = 10
    contentView.addSubview(mainStackView)
    activate(
      mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
      mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
      mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
      mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14)
    )
    mainStackView.addArrangedSubview(imageStackView)
    imageStackView.axis = .vertical
    imageStackView.addArrangedSubview(buildingImageView)

    mainStackView.addArrangedSubview(infoStackView)
    infoStackView.axis = .vertical
    infoStackView.spacing = 5
    infoStackView.addArrangedSubview(titleLabel)
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
    [
      architectsLabel,
      constructionYearsLabel,
      stylesLabel,
      addressLabel
    ].forEach { $0.font = .systemFont(ofSize: 12, weight: .light) }
  }
}
