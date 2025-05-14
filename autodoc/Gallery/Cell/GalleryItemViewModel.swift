//
//  GalleryItemViewModel.swift
//  autodoc
//
//  Created by Артём Зайцев on 14.05.2025.
//

import Combine
import UIKit

final class GalleryItemViewModel {
    var imageSubject = PassthroughSubject<UIImage, Never>()
    var imageFetchTask: Task<Void, Error>?
    
    init(url: URL) {
        configure(url: url)
    }
    
    deinit {
        imageFetchTask?.cancel()
    }
    
    func configure(url: URL) {
        imageFetchTask = Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return }
            let processedImage: UIImage = { [image] in
                guard !image.isPortraitOriented else { return image }
                return image.rotate(radians: .pi / 2)
            }()
            
            await MainActor.run {
                imageSubject.send(processedImage)
            }
        }
    }
}
