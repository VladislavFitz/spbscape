//
//  SearchOverlayViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 05.02.2022.
//  Copyright © 2022 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class SearchOverlayViewController: UIViewController {
  
  let searchTextField: UISearchTextField
  let childViewController: UIViewController
  var didTapFilterButton: ((UIButton) -> Void)?

  private let stackView: UIStackView
  private let topView: UIView
  private let searchBarContainer: UIStackView
  private let placeHolderView: UIView
  private let backgroundView: UIVisualEffectView
  private let filterButton: UIButton
  
  init(childViewController: UIViewController) {
    self.stackView = UIStackView()
    self.topView = UIView()
    self.searchBarContainer = UIStackView()
    self.placeHolderView = UIView()
    self.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    self.searchTextField = .init()
    self.childViewController = childViewController
    self.filterButton = UIButton()
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
    filterButton.translatesAutoresizingMaskIntoConstraints = false
    filterButton.setImage(UIImage(systemName: "line.horizontal.3.decrease.circle"), for: .normal)
    filterButton.contentVerticalAlignment = .fill
    filterButton.contentHorizontalAlignment = .fill
    filterButton.addTarget(self, action: #selector(didTapFilterButton(_:)), for: .touchUpInside)
    
    // Configure stack view
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = 0

    // Configure background view
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    backgroundView.clipsToBounds = true
    backgroundView.layer.cornerRadius = 10
    backgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    
    // Configure top view
    topView.translatesAutoresizingMaskIntoConstraints = false

    // Configure search text field
    searchTextField.translatesAutoresizingMaskIntoConstraints = false

    // Configure search bar container
    searchBarContainer.translatesAutoresizingMaskIntoConstraints = false
    searchBarContainer.axis = .horizontal
    searchBarContainer.spacing = 7
    searchBarContainer.alignment = .center
    
    // Configure placeholder view
    placeHolderView.translatesAutoresizingMaskIntoConstraints = false
    
    // Configure child view
    let childView = childViewController.view!
    childView.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(backgroundView)
    backgroundView.pin(to: view)
    backgroundView.contentView.addSubview(stackView)
    stackView.pin(to: backgroundView, insets: .init(top: 0, left: 10, bottom: 0, right: -10))
    searchBarContainer.addArrangedSubview(searchTextField)
    searchBarContainer.addArrangedSubview(filterButton)
    
    activate(
      filterButton.widthAnchor.constraint(equalToConstant: 28),
      filterButton.heightAnchor.constraint(equalToConstant: 28),
      topView.heightAnchor.constraint(equalToConstant: 12),
      searchBarContainer.heightAnchor.constraint(equalToConstant: 44),
      placeHolderView.heightAnchor.constraint(equalToConstant: 40)
    )
    
    stackView.addArrangedSubview(topView)
    stackView.addArrangedSubview(searchBarContainer)
    stackView.addArrangedSubview(placeHolderView)
    stackView.addArrangedSubview(childViewController.view)
  }
  
  @objc private func didTapFilterButton(_ filterButton: UIButton) {
    didTapFilterButton?(filterButton)
  }

}
