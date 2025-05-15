//
//  GalleryDiffableDataSource.swift
//  autodoc
//
//  Created by Артём Зайцев on 13.05.2025.
//

import Combine
import UIKit

final class GalleryDiffableDataSource: UICollectionViewDiffableDataSource<Int, URL> {
    private static func cellProvider(collectionView: UICollectionView,
                                     indexPath: IndexPath,
                                     url: URL) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryItemCell.reuseIdentifier,
                                                            for: indexPath) as? GalleryItemCell
        else { return UICollectionViewCell() }
        
        let viewModel = GalleryItemViewModel(url: url)
        cell.configure(with: viewModel)
        return cell
    }
    
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView,
                   cellProvider: Self.cellProvider)
    }
}
