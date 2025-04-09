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
}
