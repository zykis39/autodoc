//
//  GalleryDiffableDataSource.swift
//  autodoc
//
//  Created by Артём Зайцев on 13.05.2025.
//

import UIKit

final class GalleryDiffableDataSource: UICollectionViewDiffableDataSource<Int, URL> {
    init(collectionView: UICollectionView,
         cellRegistration: UICollectionView.CellRegistration<GalleryItemCell, URL>) {
        super.init(collectionView: collectionView) { collectionView, indexPath, url in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                         for: indexPath,
                                                         item: url)
        }
    }
}
