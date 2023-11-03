//
//  SearchHeaderViewController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 12.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Combine
import Foundation
import UIKit

final class SearchHeaderViewController: UIViewController {
  let searchTextField: UISearchTextField
  var didTapFilterButton: ((UIButton) -> Void)?

  var compactHeight: CGFloat {
    handleViewHeight +
      searchBarHeight +
      footerViewHeight +
      3 * stackSpacing
  }

  private let handleViewHeight: CGFloat = 14
  private let searchBarHeight: CGFloat = 36
  private let footerViewHeight: CGFloat = 40
  private let stackSpacing: CGFloat = 10

  var style: Style

  private let resultsCountViewModel: ResultsCountViewModel
  private let filtersStateViewModel: FiltersStateViewModel

  private let mainStackView: UIStackView
  private let headerView: HandleView
  private let bodyStackView: UIStackView
  private let footerView: UIView
  private let filtersButton: UIButton
  private let resultsCountLabel: UILabel

  private var filtersStateSubscriber: AnyCancellable?
  private var resultsCountSubscriber: AnyCancellable?

  init(filtersStateViewModel: FiltersStateViewModel,
       resultsCountViewModel: ResultsCountViewModel,
       style: Style) {
    headerView = HandleView(autolayout: ())
    bodyStackView = UIStackView(autolayout: ())
    mainStackView = UIStackView(autolayout: ())
    searchTextField = UISearchTextField(autolayout: ())
    filtersButton = UIButton(autolayout: ())
    resultsCountLabel = UILabel(autolayout: ())
    footerView = UIView(autolayout: ())
    self.style = style
    self.resultsCountViewModel = resultsCountViewModel
    self.filtersStateViewModel = filtersStateViewModel
    super.init(nibName: nil, bundle: nil)
    filtersStateSubscriber = filtersStateViewModel
      .$filtersButtonImage
      .receive(on: DispatchQueue.main)
      .sink { [weak filtersButton] image in
        filtersButton?.setImage(image, for: .normal)
      }
    resultsCountSubscriber = resultsCountViewModel
      .$resultsCountTitle
      .receive(on: DispatchQueue.main)
      .map { $0 as String? }
      .assign(to: \.text, on: resultsCountLabel)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayout()
    setupMainStackView()
    setupBodyStackView()
    setupHeaderView()
    setupFiltersButton()
    setupResultsCountLabel()
  }

  @objc func didTapFilterButton(_ filterButton: UIButton) {
    didTapFilterButton?(filterButton)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension SearchHeaderViewController {
  func setupLayout() {
    footerView.addSubview(resultsCountLabel)
    activate(
      resultsCountLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor, constant: -7),
      resultsCountLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 5),
      resultsCountLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -5)
    )

    bodyStackView.addArrangedSubview(.placeHolder(width: 14))
    bodyStackView.addArrangedSubview(searchTextField)
    if style == .overlay {
      bodyStackView.addArrangedSubview(.placeHolder(width: 7))
      bodyStackView.addArrangedSubview(filtersButton)
    }
    bodyStackView.addArrangedSubview(.placeHolder(width: 14))

    activate(
      headerView.heightAnchor.constraint(equalToConstant: handleViewHeight),
      bodyStackView.heightAnchor.constraint(equalToConstant: searchBarHeight),
      searchTextField.heightAnchor.constraint(equalToConstant: searchBarHeight),
      footerView.heightAnchor.constraint(equalToConstant: footerViewHeight),
      filtersButton.widthAnchor.constraint(equalToConstant: 28),
      filtersButton.heightAnchor.constraint(equalToConstant: 28)
    )

    view.addSubview(mainStackView)
    mainStackView.pin(to: view)
    mainStackView.addArrangedSubview(headerView)
    mainStackView.addArrangedSubview(bodyStackView)
    if style == .overlay {
      mainStackView.addArrangedSubview(footerView)
    }
  }

  func setupMainStackView() {
    mainStackView.axis = .vertical
    mainStackView.spacing = stackSpacing
  }

  func setupFiltersButton() {
    filtersButton.contentVerticalAlignment = .fill
    filtersButton.contentHorizontalAlignment = .fill
    filtersButton.addTarget(self, action: #selector(didTapFilterButton(_:)), for: .touchUpInside)
  }

  func setupResultsCountLabel() {
    resultsCountLabel.textColor = ColorScheme.primaryColor
    resultsCountLabel.textAlignment = .center
  }

  func setupHeaderView() {
    #if targetEnvironment(macCatalyst)
      headerView.isHidden = true
    #endif
    headerView.handleBar.isHidden = style == .fullscreen
  }

  func setupBodyStackView() {
    bodyStackView.axis = .horizontal
    bodyStackView.spacing = 0
    bodyStackView.alignment = .center
  }
}

extension SearchHeaderViewController {
  enum Style {
    case overlay
    case fullscreen
  }
}
