//
//  GalleryItemCell.swift
//  autodoc
//
//  Created by Артём Зайцев on 12.05.2025.
//

import Combine
import UIKit

final class GalleryItemCell: UICollectionViewCell {
    private enum Constants {
        static let vInset: CGFloat = 32
        static let cornerRadius: CGFloat = 8
        static let backgroundColor: UIColor = UIColor.init(hex: "#1B1B1DFF")!
    }
    
    private let imageView = UIImageView()
        .set(\.translatesAutoresizingMaskIntoConstraints, to: false)
        .set(\.contentMode, to: .scaleAspectFill)
        .set(\.clipsToBounds, to: true)
    private var cancellables = Set<AnyCancellable>()
    static let reuseIdentifier = "gallery_item_cell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = Constants.cornerRadius
    }
    
    func configure(with viewModel: GalleryItemViewModel) {
        viewModel.imageSubject
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: imageView)
            .store(in: &cancellables)
    }
    
    // MARK: - Private
    private func commonInit() {
        contentView.backgroundColor = Constants.backgroundColor
        contentView.addSubview(imageView)
        
        let topConstraint = imageView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                           constant: Constants.vInset)
        let bottomConstraint = imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                                 constant: -Constants.vInset)
        let leadingConstraint = imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        let trailingConstraint = imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        let constraints = [topConstraint,
                           bottomConstraint,
                           leadingConstraint,
                           trailingConstraint]
        contentView.addConstraints(constraints)
        constraints.forEach { $0.isActive = true }
    }
}
