//
//  SearchViewController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 05.02.2022.
//  Copyright © 2022 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
#if targetEnvironment(macCatalyst)
import Combine
#endif



final class SearchViewController: UIViewController {
  
  let searchTextField: UISearchTextField
  let childViewController: UIViewController
  var didTapFilterButton: ((UIButton) -> Void)?
  
  var compactHeight: CGFloat {
    handleViewHeight +
    searchBarHeight +
    footerViewHeight +
    3 * stackSpacing
  }
  
  var style: Style
  
  private let resultsCountViewModel: ResultsCountViewModel
  private let filtersStateViewModel: FiltersStateViewModel
  
  private let backgroundView: UIVisualEffectView
  private let mainStackView: UIStackView
  private let headerView: HandleView
  private let bodyStackView: UIStackView
  private let footerView: UIView
  private let filtersButton: UIButton
  private let resultsCountLabel: UILabel
  
  #if targetEnvironment(macCatalyst)
  var showFilterSubscriber: AnyCancellable?
  #endif
    
  private let handleViewHeight: CGFloat = 14
  private let searchBarHeight: CGFloat = 36
  private let footerViewHeight: CGFloat = 40
  private let stackSpacing: CGFloat = 10
    
  init(childViewController: UIViewController,
       filtersStateViewModel: FiltersStateViewModel,
       resultsCountViewModel: ResultsCountViewModel,
       style: Style) {
    self.mainStackView = UIStackView()
    self.headerView = HandleView()
    self.bodyStackView = UIStackView()
    self.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    self.searchTextField = UISearchTextField()
    self.childViewController = childViewController
    self.filtersButton = UIButton()
    self.resultsCountLabel = UILabel()
    self.footerView = UIView()
    self.style = style
    self.resultsCountViewModel = resultsCountViewModel
    self.filtersStateViewModel = filtersStateViewModel
    super.init(nibName: .none, bundle: .none)
    addChild(childViewController)
    childViewController.didMove(toParent: self)
    filtersStateViewModel.addObserver(self)
    resultsCountViewModel.addObserver(self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupBackgroundView()
    setupMainStackView()
    setupBodyStackView()
    setupHeaderView()
    setupFooterView()
    setupFiltersButton()
    setupResultsCountLabel()
    setupSearchTextField()
    setupLayout()
  }
  
  @objc func didTapFilterButton(_ filterButton: UIButton) {
    didTapFilterButton?(filterButton)
  }
  
  deinit {
    resultsCountViewModel.removeObserver(self)
    filtersStateViewModel.removeObserver(self)
  }

}

private extension SearchViewController {
  
  func setupLayout() {
      
    footerView.addSubview(resultsCountLabel)
    activate(
      resultsCountLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor, constant: -7),
      resultsCountLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 5),
      resultsCountLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -5)
    )

    view.addSubview(backgroundView)
    
    let topAnchor: NSLayoutYAxisAnchor
    #if targetEnvironment(macCatalyst)
    topAnchor = view.safeAreaLayoutGuide.topAnchor
    #else
    topAnchor = view.topAnchor
    #endif
    
    activate(
      backgroundView.topAnchor.constraint(equalTo: topAnchor),
      backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      backgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      backgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
    )
    backgroundView.contentView.addSubview(mainStackView)
    let mainStackViewInsets = UIEdgeInsets(top: 5,
                                           left: 0,
                                           bottom: 0,
                                           right: 0)
    mainStackView.pin(to: backgroundView,
                  insets: mainStackViewInsets)

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
      footerView.heightAnchor.constraint(equalToConstant: footerViewHeight),
      filtersButton.widthAnchor.constraint(equalToConstant: 28),
      filtersButton.heightAnchor.constraint(equalToConstant: 28)
    )
    
    mainStackView.addArrangedSubview(headerView)
    mainStackView.addArrangedSubview(bodyStackView)
    if style == .overlay {
      mainStackView.addArrangedSubview(footerView)
    }

    let childView = childViewController.view!
    childView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.addArrangedSubview(childViewController.view)
  }

  
  func setupFiltersButton() {
    filtersButton.setImage(filtersStateViewModel.filtersButtonImage(), for: .normal)
    filtersButton.contentVerticalAlignment = .fill
    filtersButton.contentHorizontalAlignment = .fill
    filtersButton.addTarget(self, action: #selector(didTapFilterButton(_:)), for: .touchUpInside)
  }
  
  func setupResultsCountLabel() {
    resultsCountLabel.text = resultsCountViewModel.resultsCountTitle()
    resultsCountLabel.textColor = ColorScheme.primaryColor
    resultsCountLabel.textAlignment = .center
    resultsCountLabel.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func setupBackgroundView() {
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    backgroundView.clipsToBounds = true
    if style == .overlay {
      backgroundView.layer.cornerRadius = 12
      backgroundView.layer.maskedCorners = [
        .layerMaxXMinYCorner,
        .layerMinXMinYCorner
      ]
    }
  }
  
  func setupHeaderView() {
    headerView.translatesAutoresizingMaskIntoConstraints = false
    #if targetEnvironment(macCatalyst)
    headerView.isHidden = true
    #endif
    headerView.handleBar.isHidden = style == .fullscreen
  }
  
  func setupFooterView() {
    footerView.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func setupSearchTextField() {
    searchTextField.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func setupBodyStackView() {
    bodyStackView.translatesAutoresizingMaskIntoConstraints = false
    bodyStackView.axis = .horizontal
    bodyStackView.spacing = 0
    bodyStackView.alignment = .center
  }
  
  func setupMainStackView() {
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.axis = .vertical
    mainStackView.spacing = stackSpacing
  }
  
}

extension SearchViewController {
  
  enum Style {
    case overlay
    case fullscreen
  }
  
}

extension SearchViewController: ResultsCountObserver {
  
  func setResultsCount(_ resultsCount: String) {
    resultsCountLabel.text = resultsCount
  }
  
}

extension SearchViewController: FiltersStateObserver {
  
  func setFiltersEmpty(_ empty: Bool) {
    filtersButton.setImage(filtersStateViewModel.filtersButtonImage(), for: .normal)
  }
  
}
