//
//  BuildingViewController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import SpbscapeCore

final class BuildingViewController: UIViewController {
  
  let building: Building
  
  let titleLabel: UILabel
  let galleryViewController: GalleryViewController
  let goToCityWallsButton: UIButton
  
  init(building: Building) {
    self.building = building
    self.titleLabel = .init()
    self.galleryViewController = .init(images: building.photos.map(\.url))
    self.goToCityWallsButton = .init()
    super.init(nibName: nil, bundle: nil)
    title = building.titles.joined(separator: ", ")
    titleLabel.text = building.titles.joined(separator: ", ")
    titleLabel.font = .systemFont(ofSize: 24, weight: .heavy)
    titleLabel.numberOfLines = 0
    configureLayout()
    addChild(galleryViewController)
    galleryViewController.willMove(toParent: self)
    galleryViewController.view.translatesAutoresizingMaskIntoConstraints = false
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImage(_:)))
    galleryViewController.view.addGestureRecognizer(tapGestureRecognizer)
    configureButton()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
      
  func configureLayout() {
    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(backgroundView)
    activate(
      backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
      backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    )
    
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 6
    stackView.distribution = .fill
    view.addSubview(stackView)
    
    galleryViewController.pageControl.hidesForSinglePage = true
    galleryViewController.pageControl.pageIndicatorTintColor = .lightGray
    galleryViewController.pageControl.currentPageIndicatorTintColor = ColorScheme.primaryColor

    galleryViewController.pageControl.layer.masksToBounds = true
    galleryViewController.pageControl.translatesAutoresizingMaskIntoConstraints = false
    
    let imageStackView = UIStackView()
    imageStackView.axis = .vertical
    imageStackView.translatesAutoresizingMaskIntoConstraints = false
    imageStackView.addArrangedSubview(galleryViewController.view)
    imageStackView.addArrangedSubview(galleryViewController.pageControl)
    stackView.addArrangedSubview(imageStackView)

    [
      ("address".localize(), building.addresses.map(\.description)),
      ("architects".localize(), building.architects.map(\.title)),
      ("\("yearsOfConstruction".localize())", building.constructionYears.map(\.description)),
      ("style".localize(), building.styles.map(\.title)),
    ]
      .filter { !$0.1.isEmpty }
      .map { getSV(title: $0.0, values: $0.1) }
      .forEach(stackView.addArrangedSubview)
    
    stackView.addArrangedSubview(.init())
    
    goToCityWallsButton.translatesAutoresizingMaskIntoConstraints = false
    let placeholder = UIView()
    placeholder.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(placeholder)
    stackView.addArrangedSubview(goToCityWallsButton)
    
    let stackViewContainer = UIView()
    stackViewContainer.translatesAutoresizingMaskIntoConstraints = false
    stackViewContainer.addSubview(stackView)
    activate(
      stackView.topAnchor.constraint(equalTo: stackViewContainer.safeAreaLayoutGuide.topAnchor, constant: 7),
      stackView.leadingAnchor.constraint(equalTo: stackViewContainer.leadingAnchor, constant: 7),
      stackView.trailingAnchor.constraint(equalTo: stackViewContainer.trailingAnchor, constant: -7),
      stackView.bottomAnchor.constraint(equalTo: stackViewContainer.bottomAnchor, constant: -7)
    )
    
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(stackViewContainer)
    stackViewContainer.pin(to: scrollView)
    
    view.addSubview(scrollView)
    
    activate(
      stackViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      stackViewContainer.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      galleryViewController.view.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.5),
      goToCityWallsButton.heightAnchor.constraint(equalToConstant: 44)
    )

  }
  
  func configureButton() {
    goToCityWallsButton.setTitle("Перейти на CityWalls", for: .normal)
    goToCityWallsButton.backgroundColor = ColorScheme.primaryColor
    goToCityWallsButton.layer.cornerRadius = 10
    goToCityWallsButton.addTarget(self, action: #selector(goToCityWalls), for: .touchUpInside)
  }

  func getSV(title: String, values: [String]) -> UIStackView {
    let stackView = UIStackView()
      .set(\.translatesAutoresizingMaskIntoConstraints, to: false)
      .set(\.axis, to: .vertical)
      .set(\.distribution, to: .fillEqually)
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = .systemFont(ofSize: 12, weight: .light)
    stackView.addArrangedSubview(titleLabel)
    stackView.alignment = .top
    let valueLabel = UILabel()
    valueLabel.numberOfLines = 0
    valueLabel.text = values.joined(separator: ", ")
    valueLabel.font = .systemFont(ofSize: 14, weight: .semibold)
    stackView.addArrangedSubview(valueLabel)
//    let valuesStackView = UIStackView()
//      .set(\.translatesAutoresizingMaskIntoConstraints, to: false)
//      .set(\.axis, to: .vertical)
//      .set(\.alignment, to: .leading)
//    for value in values {
//      let valueLabel = UILabel()
//      valueLabel.text = value
//      valuesStackView.addArrangedSubview(valueLabel)
//    }
//    valuesStackView.addArrangedSubview(.init())
//    stackView.addArrangedSubview(valuesStackView)
    return stackView
  }
  
  @objc func goToCityWalls() {
    UIApplication.shared.open(building.buildingURL)
  }
  
  @objc func didTapImage(_ tapGestureRecognizer: UITapGestureRecognizer) {
    guard presentedViewController == .none else { return }
    let galleryViewController = GalleryViewController(images: building.photos.map(\.url))
    galleryViewController.title = title
    galleryViewController.preselectedIndex = self.galleryViewController.currentIndexPath?.item
    galleryViewController.view.backgroundColor = .systemBackground
    let navigationController = UINavigationController(rootViewController: galleryViewController)
    let navigationBarAppearance = UINavigationBarAppearance()
    navigationBarAppearance.configureWithDefaultBackground()
    navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    galleryViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                                                              style: .done,
                                                                              target: self,
                                                                              action: #selector(dismissFullscreenGallery))
    navigationController.modalPresentationStyle = .fullScreen
    present(navigationController, animated: true)
  }
  
  @objc func dismissFullscreenGallery() {
    presentedViewController?.dismiss(animated: true, completion: nil)
  }
  
}

extension Building {
  
  var buildingURL: URL { URL(string: "https://www.citywalls.ru/house\(id).html")! }
  
}
