//
//  GalleryItemViewModel.swift
//  autodoc
//
//  Created by Артём Зайцев on 14.05.2025.
//

import Combine
import UIKit

final class GalleryItemViewModel {
    private let url: URL
    
    init(url: URL) {
        self.url = url
    }
}

extension GalleryItemViewModel {
    public func getImage() async throws -> UIImage? {
        let (data, _) = try await URLSession.shared.data(from: self.url)
        
        guard let image = UIImage(data: data) else { return nil }
        let processedImage: UIImage = { [image] in
            guard !image.isPortraitOriented else { return image }
            return image.rotate(radians: .pi / 2)
        }()
        
        return processedImage
    }
}
