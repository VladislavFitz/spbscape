//
//  GalleryViewController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class GalleryViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  let images: [URL]
  let pageControl: UIPageControl
  
  var preselectedIndex: Int?
  
  private var cellIdentifier: String { #function }
  
  init(images: [URL]) {
    self.images = images
    self.pageControl = UIPageControl()
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    super.init(collectionViewLayout: layout)
    configurePageControl()
    configureCollectionView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  fileprivate var prevIndexPathAtCenter: IndexPath?

  var currentIndexPath: IndexPath? {
      let center = view.convert(collectionView.center, to: collectionView)
      return collectionView.indexPathForItem(at: center)
  }
    
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    if let indexAtCenter = currentIndexPath {
        prevIndexPathAtCenter = indexAtCenter
    }
    collectionView.collectionViewLayout.invalidateLayout()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    scrollToPreselectedIndex()
  }
  
  @objc func scrollToPreselectedIndex() {
    guard let preselectedIndex = preselectedIndex else {
      return
    }
    collectionView.contentOffset.x = CGFloat(preselectedIndex) * collectionView.bounds.width
  }
    
  private func configureCollectionView() {
    collectionView.register(ImageCell.self, forCellWithReuseIdentifier: cellIdentifier)
    collectionView.isPagingEnabled = true
    collectionView.backgroundView = .init()
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
  }
  
  private func configurePageControl() {
    pageControl.tintColor = ColorScheme.primaryColor
    pageControl.numberOfPages = images.count
    pageControl.addTarget(self, action: #selector(onPageChange(_:)), for: .valueChanged)
  }
  
  @objc private func onPageChange(_ pageControl: UIPageControl) {
    collectionView.scrollToItem(at: .init(item: pageControl.currentPage, section: 0), at: .centeredHorizontally, animated: true)
  }
      
  //MARK: - CollectionView DataSource
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    images.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
  }
  
  //MARK: - CollectionView Delegate
  
  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    guard let imageCell = cell as? ImageCell else { return }
    imageCell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.large
    imageCell.imageView.sd_setImage(with: images[indexPath.row], placeholderImage: .placeholder)
    imageCell.imageView.contentMode = .scaleAspectFit
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    .zero
  }
  
  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    pageControl.currentPage = Int(collectionView.contentOffset.x) / Int(collectionView.frame.width)
  }
  
  override func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
    guard let oldCenter = prevIndexPathAtCenter else {
      return proposedContentOffset
    }
    let attrs = collectionView.layoutAttributesForItem(at: oldCenter)
    let newOriginForOldIndex = attrs?.frame.origin
    return newOriginForOldIndex ?? proposedContentOffset
  }
  
}
