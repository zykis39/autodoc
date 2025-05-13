//
//  GalleryCompositionLayout.swift
//  autodoc
//
//  Created by Артём Зайцев on 12.05.2025.
//

import Combine
import UIKit

final class GalleryCompositionLayout: UICollectionViewCompositionalLayout {
    private enum Constants {
        static let inset: CGFloat = 16
    }
    let currentPageSubject: CurrentValueSubject<Int, Never> = .init(0)
    
    init() {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let inset = Constants.inset
        item.contentInsets = .init(top: inset,
                                   leading: inset,
                                   bottom: inset,
                                   trailing: inset)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.visibleItemsInvalidationHandler = { [currentPageSubject] visibleItems, scrollOffset, layoutEnvironment in
            guard let lastIndex = visibleItems.last?.indexPath.row else { return }
            
            guard visibleItems.count > 1 else {
                currentPageSubject.send(lastIndex)
                return
            }
            // FIXME: last page, offset > 0. bugged
            let itemHInset: CGFloat = 16
            
            let firstIndex = lastIndex - 1
            let width = layoutEnvironment.container.contentSize.width
            let offset = Double(Int(scrollOffset.x) % Int(width))
            if offset < itemHInset {
                currentPageSubject.send(lastIndex)
            } else if offset < width / 2 {
                currentPageSubject.send(firstIndex)
            } else {
                currentPageSubject.send(lastIndex)
            }
        }
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        super.init(section: section, configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
