//
//  GalleryItemCell.swift
//  autodoc
//
//  Created by Артём Зайцев on 12.05.2025.
//

import Combine
import UIKit

final class GalleryItemCell: UICollectionViewCell {
    static let nibName = "GalleryItemCell"
    
    @IBOutlet var imageView: UIImageView!
    private var cancellables = Set<AnyCancellable>()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        cancellables.removeAll()
    }
    
    func configure(with viewModel: GalleryItemViewModel) {
        Task { [weak self] in
            let image = try? await viewModel.getImage()
            self?.imageView.image = image
        }
    }
}
