//
//  GalleryViewController.swift
//  CityWalls
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
  
  private func configureCollectionView() {
    collectionView.register(ImageCell.self, forCellWithReuseIdentifier: cellIdentifier)
    collectionView.isPagingEnabled = true
    collectionView.backgroundView = .init()
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
  }
  
  private func configurePageControl() {
    pageControl.numberOfPages = images.count
    pageControl.addTarget(self, action: #selector(onPageChange(_:)), for: .valueChanged)
  }
  
  @objc private func onPageChange(_ pageControl: UIPageControl) {
    collectionView.scrollToItem(at: IndexPath(item: pageControl.currentPage, section: 0), at: .centeredHorizontally, animated: true)
  }
  
  //MARK: - CollectionView DataSource
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
  }
  
  //MARK: - CollectiView Delegate
  
  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    guard let imageCell = cell as? ImageCell else { return }
    imageCell.imageView.sd_setImage(with: images[indexPath.row])
    imageCell.imageView.contentMode = .scaleAspectFit
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return .init(width: collectionView.frame.width, height: collectionView.frame.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
  }
  
}
