//
//  GalleryViewModel.swift
//  autodoc
//
//  Created by Артём Зайцев on 12.05.2025.
//

import Foundation
import Combine

final class GalleryViewModel {
    @Published var subtitle: String?
    @Published var imageURLs: [URL]
    
    init(subtitle: String?, imageURLs: [URL]) {
        self.subtitle = subtitle
        self.imageURLs = imageURLs
    }
}
