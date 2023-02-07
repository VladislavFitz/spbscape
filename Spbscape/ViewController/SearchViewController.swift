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


class SearchViewController: UIViewController {
  
  let searchTextField: UISearchTextField
  let childViewController: UIViewController
  var didTapFilterButton: ((UIButton) -> Void)?
  
  var compactHeight: CGFloat {
    handleViewHeight +
    searchBarHeight +
    hitsCountViewHeight +
    3 * stackSpacing
  }
  
  func setHitsCount(_ hitsCount: Int) {
    self.hitsCountView.countLabel.text = "\("buildings".localize()): \(hitsCount)"
  }
  
  var style: Style
  private let stackView: UIStackView
  let handleView: HandleView
  private let searchBarContainer: UIStackView
  let hitsCountView: HitsCountView
  private let backgroundView: UIVisualEffectView
  let filterButton: UIButton
  
  #if targetEnvironment(macCatalyst)
  var showFilterSubscriber: AnyCancellable?
  #endif
    
  private let handleViewHeight: CGFloat = 14
  private let searchBarHeight: CGFloat = 36
  private let hitsCountViewHeight: CGFloat = 40
  private let stackSpacing: CGFloat = 10
    
  init(childViewController: UIViewController,
       style: Style,
       filterButton: UIButton) {
    self.stackView = UIStackView()
    self.handleView = HandleView()
    self.searchBarContainer = UIStackView()
    self.hitsCountView = HitsCountView()
    self.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    self.searchTextField = UISearchTextField()
    self.childViewController = childViewController
    self.filterButton = filterButton
    self.style = style
    super.init(nibName: .none, bundle: .none)
    addChild(childViewController)
    childViewController.didMove(toParent: self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayout()
  }
  
  fileprivate func setupLayout() {
    
    // Configure filter button
    filterButton.addTarget(self, action: #selector(didTapFilterButton(_:)), for: .touchUpInside)
    
    // Configure stack view
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = stackSpacing

    // Configure background view
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    backgroundView.clipsToBounds = true
    if style == .overlay {
      backgroundView.layer.cornerRadius = 12
      backgroundView.layer.maskedCorners = [
        .layerMaxXMinYCorner,
        .layerMinXMinYCorner
      ]
    }
    
    // Configure handle view
    handleView.handleBar.isHidden = style == .fullscreen
    handleView.translatesAutoresizingMaskIntoConstraints = false

    // Configure search text field
    searchTextField.translatesAutoresizingMaskIntoConstraints = false

    // Configure search bar container
    searchBarContainer.translatesAutoresizingMaskIntoConstraints = false
    searchBarContainer.axis = .horizontal
    searchBarContainer.spacing = 0
    searchBarContainer.alignment = .center
    
    // Configure placeholder view
    hitsCountView.translatesAutoresizingMaskIntoConstraints = false
    
    // Configure child view
    let childView = childViewController.view!
    childView.translatesAutoresizingMaskIntoConstraints = false

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
    backgroundView.contentView.addSubview(stackView)
    stackView.pin(to: backgroundView,
                  insets: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0))

    searchBarContainer.addArrangedSubview(.placeHolder(width: 14))
    searchBarContainer.addArrangedSubview(searchTextField)
    if style == .overlay {
      searchBarContainer.addArrangedSubview(.placeHolder(width: 7))
      searchBarContainer.addArrangedSubview(filterButton)
    }
    searchBarContainer.addArrangedSubview(.placeHolder(width: 14))
    
    activate(
      handleView.heightAnchor.constraint(equalToConstant: handleViewHeight),
      searchBarContainer.heightAnchor.constraint(equalToConstant: searchBarHeight),
      hitsCountView.heightAnchor.constraint(equalToConstant: hitsCountViewHeight)
    )
    
    stackView.addArrangedSubview(handleView)
    stackView.addArrangedSubview(searchBarContainer)
    if style == .overlay {
      stackView.addArrangedSubview(hitsCountView)
    }
    stackView.addArrangedSubview(childViewController.view)
  }
  
  @objc func didTapFilterButton(_ filterButton: UIButton) {
    didTapFilterButton?(filterButton)
  }

}

extension SearchViewController {
  
  enum Style {
    case overlay
    case fullscreen
  }
  
}
