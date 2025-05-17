//
//  GalleryViewModel.swift
//  autodoc
//
//  Created by Артём Зайцев on 12.05.2025.
//

import Foundation
import Combine
import UIKit

final class GalleryViewModel {
    typealias DataSource = GalleryDiffableDataSource
    typealias LayoutHandler = NSCollectionLayoutSectionVisibleItemsInvalidationHandler
    
    private var dataSource: DataSource?
    
    public let imageURLs: [URL]
    public let subtitle: String?
    
    public let currentPageSubject = CurrentValueSubject<Int, Never>(0)
    
    init(subtitle: String?, imageURLs: [URL]) {
        self.subtitle = subtitle
        self.imageURLs = imageURLs
    }
}

extension GalleryViewModel {
    public func onViewDidLoad() {
        guard let snapshot = dataSource?.makeSnapshot(urls: imageURLs) else { return }
        dataSource?.apply(snapshot)
    }
}

extension GalleryViewModel {
    public func makeDataSource(_ collectionView: UICollectionView) -> DataSource {
        let cellRegistration = UICollectionView.CellRegistration<GalleryItemCell, URL>(cellNib: UINib(nibName: GalleryItemCell.nibName, bundle: nil)) { (cell: GalleryItemCell, indexPath: IndexPath, url: URL) in
            let viewModel = GalleryItemViewModel(url: url)
            cell.set(viewModel: viewModel)
        }
        
        let dataSource = GalleryDiffableDataSource(collectionView: collectionView, cellRegistration: cellRegistration)
        self.dataSource = dataSource
        return dataSource
    }
}

extension GalleryViewModel {
    public func configureInvalidation() -> LayoutHandler {
        return { [weak self] (_ : [any NSCollectionLayoutVisibleItem], scrollOffset: CGPoint, layoutEnvironment: any NSCollectionLayoutEnvironment) in
            let width = layoutEnvironment.container.contentSize.width
            let index = Int((scrollOffset.x / width).rounded(.toNearestOrAwayFromZero))
            self?.currentPageSubject.send(index)
        }
    }
}
