//
//  GalleryCompositionLayout.swift
//  autodoc
//
//  Created by Артём Зайцев on 12.05.2025.
//

import Combine
import UIKit

final class GalleryCompositionLayout: UICollectionViewCompositionalLayout {
    typealias LayoutHandler = NSCollectionLayoutSectionVisibleItemsInvalidationHandler
    
    private struct Config {
        static let sectionSpacing: CGFloat = 16
    }
    
    private enum Section: Int {
        case main
        
        public init?(rawValue: Int) {
            switch rawValue {
            case 0: self = .main
            default: return nil
            }
        }
    }
    
    convenience init(layoutHandler: @escaping LayoutHandler) {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        self.init(sectionProvider: { section, _ in
            Self.sectionProvider(section: section,
                                 layoutHandler: layoutHandler)
        }, configuration: configuration)
    }
}

extension GalleryCompositionLayout {
    private static func sectionProvider(section: Int,
                                layoutHandler: LayoutHandler?) -> NSCollectionLayoutSection? {
        guard let section = Section(rawValue: section) else { return nil }
        return configureSection(section, layoutHandler: layoutHandler)
    }
    
    private static func configureSection(_ section: Section, layoutHandler: LayoutHandler? = nil) -> NSCollectionLayoutSection {
        switch section {
        case .main:
            let inset = Config.sectionSpacing
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: inset,
                                       leading: inset,
                                       bottom: inset,
                                       trailing: inset)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           repeatingSubitem: item,
                                                           count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
            section.visibleItemsInvalidationHandler = layoutHandler
            return section
        }
    }
}
