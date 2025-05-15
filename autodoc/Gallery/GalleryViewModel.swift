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
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, URL>
    typealias DataSource = UICollectionViewDiffableDataSource<Int, URL>
    
    private var dataSource: DataSource?
    private let imageURLs: [URL]
    @Published var subtitle: String?
    var numberOfPagesSubject = CurrentValueSubject<Int, Never>(0)
    var currentPageSubject = CurrentValueSubject<Int, Never>(0)
    
    init(subtitle: String?, imageURLs: [URL]) {
        self.subtitle = subtitle
        self.imageURLs = imageURLs
        numberOfPagesSubject.send(imageURLs.count)
    }
    
    func makeDataSource(_ collectionView: UICollectionView) -> DataSource {
        let dataSource = GalleryDiffableDataSource(collectionView: collectionView)
        self.dataSource = dataSource
        return dataSource
    }
    
    func layoutHandler(visibleItems: [any NSCollectionLayoutVisibleItem],
                       scrollOffset: CGPoint,
                       layoutEnvironment: any NSCollectionLayoutEnvironment) {
        guard let lastIndex = visibleItems.last?.indexPath.row else { return }
        guard visibleItems.count > 1 else {
            currentPageSubject.send(lastIndex)
            return
        }
        
        let width = layoutEnvironment.container.contentSize.width
        let itemOffset = Double(Int(scrollOffset.x) % Int(width))
        let moreThenHalf = itemOffset > width / 2
        let index = Int(floor(scrollOffset.x / width)) + (moreThenHalf ? 1 : 0)
        currentPageSubject.send(index)
    }
    
    func onViewDidLoad() {
        dataSource?.apply(makeSnapshot(urls: imageURLs))
    }
    
    // MARK: - Private
    private func makeSnapshot(urls: [URL]) -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(urls.map { $0 })
        return snapshot
    }
}
