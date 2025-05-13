//
//  GalleryDiffableDataSource.swift
//  autodoc
//
//  Created by Артём Зайцев on 13.05.2025.
//

import UIKit

final class GalleryDiffableDataSource: UICollectionViewDiffableDataSource<Int, URL> {
    private let imageURLs: [URL]
    
    init(imageURLs: [URL], collectionView: UICollectionView) {
        self.imageURLs = imageURLs
        
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCell.reuseIdentifier, for: indexPath) as? GalleryCell,
                  let url = imageURLs[safe: indexPath.row]
            else { return UICollectionViewCell() }
            
            cell.configure(url: url)
            return cell
        }
    }
}
