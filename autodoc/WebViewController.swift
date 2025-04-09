//
//  WebViewController.swift
//  autodoc
//
//  Created by Артём Зайцев on 09.04.2025.
//
import UIKit
import WebKit

final class WebViewController: UIViewController {
    private let webView: WKWebView
    private let url: URL
    
    init(configuration: WKWebViewConfiguration, url: URL) {
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        let top = webView.topAnchor.constraint(equalTo: view.topAnchor)
        let leading = webView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let bottom = webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let trailing = webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let constraints = [top, leading, bottom, trailing]
        view.addConstraints(constraints)
        constraints.forEach { $0.isActive = true }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
