//
//  ToolpanelViewController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 12.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class ToolpanelViewController: UIViewController {
  
  let stackView: UIStackView
  let hitsCountLabel: UILabel
  let filtersButton: UIButton
  var didTapFiltersButton: ((UIButton) -> Void)?

  private let filtersStateViewModel: FiltersStateViewModel
  private let resultsCountViewModel: ResultsCountViewModel
    
  init(filtersStateViewModel: FiltersStateViewModel, resultsCountViewModel: ResultsCountViewModel) {
    self.filtersStateViewModel = filtersStateViewModel
    self.resultsCountViewModel = resultsCountViewModel
    stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.alignment = .center
    hitsCountLabel = UILabel()
    hitsCountLabel.textColor = ColorScheme.primaryColor
    hitsCountLabel.textAlignment = .center
    hitsCountLabel.translatesAutoresizingMaskIntoConstraints = false
    hitsCountLabel.text = resultsCountViewModel.resultsCountTitle()
    
    filtersButton = UIButton()
    filtersButton.contentVerticalAlignment = .fill
    filtersButton.contentHorizontalAlignment = .fill

    super.init(nibName: nil,
               bundle: nil)
    filtersButton.addTarget(self,
                            action: #selector(_didTapFiltersButton),
                            for: .touchUpInside)
    filtersButton.setImage(filtersStateViewModel.filtersButtonImage(), for: .normal)
    filtersStateViewModel.addObserver(self)
    resultsCountViewModel.addObserver(self)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    backgroundView.layer.cornerRadius = 12
    backgroundView.layer.masksToBounds = true
    view = backgroundView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    (view as? UIVisualEffectView)?.contentView.addSubview(stackView)
    let stackViewInsets = UIEdgeInsets(top: 8,
                                       left: 15,
                                       bottom: -8,
                                       right: -15)
    stackView.pin(to: view,
                  insets: stackViewInsets)
    stackView.addArrangedSubview(hitsCountLabel)
    stackView.addArrangedSubview(filtersButton)
    NSLayoutConstraint.activate([
      filtersButton.widthAnchor.constraint(equalToConstant: 28),
      filtersButton.heightAnchor.constraint(equalToConstant: 28),
    ])
  }
  
  @objc private func _didTapFiltersButton(_ filterButton: UIButton) {
    didTapFiltersButton?(filterButton)
  }
  
  deinit {
    resultsCountViewModel.removeObserver(self)
    filtersStateViewModel.removeObserver(self)
  }
  
}

extension ToolpanelViewController: ResultsCountObserver {
  
  func setResultsCount(_ resultsCount: String) {
    hitsCountLabel.text = resultsCountViewModel.resultsCountTitle()
  }

}

extension ToolpanelViewController: FiltersStateObserver {
  
  func setFiltersEmpty(_ empty: Bool) {
    filtersButton.setImage(filtersStateViewModel.filtersButtonImage(), for: .normal)
  }
  
}
