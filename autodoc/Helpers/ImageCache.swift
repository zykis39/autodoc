//
//  ImageCache.swift
//  autodoc
//
//  Created by Артём Зайцев on 09.04.2025.
//
import UIKit

final class ImageCache {
    var cache = NSCache<NSString, UIImage>()
    static let shared: ImageCache = ImageCache()
}
