//
//  NewsFeedRouter.swift
//  autodoc
//
//  Created by Артём Зайцев on 09.04.2025.
//
import UIKit
import WebKit

public protocol NewsFeedRoutable {
    @MainActor func showDetailed(url: URL)
    @MainActor func showGallery(imageURLs: [URL], subtitle: String?)
}

final class NewsFeedRouter: NewsFeedRoutable {
    let navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func showDetailed(url: URL) {
        let config = WKWebViewConfiguration()
        let vc = WebViewController(configuration: config, url: url)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showGallery(imageURLs: [URL], subtitle: String?) {
        let vc = GalleryViewController(imageURLs: imageURLs, subtitle: subtitle)
        navigationController?.pushViewController(vc, animated: true)
    }
}
