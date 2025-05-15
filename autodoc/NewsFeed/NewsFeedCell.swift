//
//  NewsFeedCell.swift
//  autodoc
//
//  Created by Артём Зайцев on 08.04.2025.
//
import UIKit

final class NewsFeedCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let label = UILabel()
    private var imageFetchTask: Task<UIImage, Error>?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        contentView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        [imageView, label].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        [imageView, label].forEach { contentView.addSubview($0) }
        label.numberOfLines = 0
        
        let imageTop = imageView.topAnchor.constraint(equalTo: contentView.topAnchor)
        let imageLeading = imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        let imageBottom = imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        let imageAspectRatio = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.0)
        let imageConstraints = [imageTop, imageLeading, imageBottom, imageAspectRatio]
        contentView.addConstraints(imageConstraints)
        imageConstraints.forEach { $0.isActive = true }
        
        let labelLeading = imageView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: 0)
        let labelTop = label.topAnchor.constraint(equalTo: contentView.topAnchor)
        let labelBottom = label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        let labelTrailing = label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        let labelConstraints = [labelLeading, labelTop, labelBottom, labelTrailing]
        contentView.addConstraints(labelConstraints)
        labelConstraints.forEach { $0.isActive = true }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        label.text = nil
        imageFetchTask?.cancel()
    }
    
    func configure(imageUrl: URL?, text: String) {
        label.text = text
        guard let imageUrl else { return }
        
        if let cachedImage = ImageCache.shared.cache.object(forKey: imageUrl.absoluteString as NSString) {
            imageView.image = cachedImage
            return
        }
        
        imageFetchTask = Task {
            let (data, _) = try await URLSession.shared.data(from: imageUrl)
            guard let image = UIImage(data: data) else { throw NSError(domain: "", code: -1) }
            return image
        }
        
        Task { [weak self] in
            let result = await self?.imageFetchTask?.result
            guard case let .success(image) = result else { return }
            ImageCache.shared.cache.setObject(image, forKey: imageUrl.absoluteString as NSString)
            await MainActor.run { self?.imageView.image = image }
        }
    }
}
