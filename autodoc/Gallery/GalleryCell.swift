//
//  GalleryCell.swift
//  autodoc
//
//  Created by Артём Зайцев on 12.05.2025.
//

import UIKit

final class GalleryCell: UICollectionViewCell {
    private enum Constants {
        static let vInset: CGFloat = 32
        static let cornerRadius: CGFloat = 8
        static let backgroundColor: UIColor = .lightGray
    }
    
    private let imageView = UIImageView()
    private var imageFetchTask: Task<UIImage, Error>?
    static let reuseIdentifier = "gallery_cell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        contentView.backgroundColor = Constants.backgroundColor
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        let topConstraint = imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.vInset)
        let bottomConstraint = imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.vInset)
        let leadingConstraint = imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        let trailingConstraint = imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        let constraints = [topConstraint, bottomConstraint, leadingConstraint, trailingConstraint]
        contentView.addConstraints(constraints)
        constraints.forEach { $0.isActive = true }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        // TODO: should be cancelled or not?
        imageFetchTask?.cancel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = Constants.cornerRadius
    }
    
    func configure(url: URL) {
        // TODO: refactor?
        imageFetchTask = Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { throw NSError(domain: "", code: -1) }
            return image
        }
        
        Task { [weak self] in
            let result = await self?.imageFetchTask?.result
            guard case let .success(image) = result else { return }
            let processedImage: UIImage = { [image] in
                guard !image.isPortraitOriented else { return image }
                return image.rotate(radians: .pi / 2)
            }()
            
            await MainActor.run {
                self?.imageView.image = processedImage
            }
        }
    }
}
