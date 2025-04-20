//
//  NewsFeedViewModel.swift
//  autodoc
//
//  Created by Артём Зайцев on 08.04.2025.
//
import Combine
import Foundation

struct NewsDataSource: Sendable {
    var data: [NewsFeedElement]
    var newData: [NewsFeedElement]
}

final class NewsFeedViewModel {
    let service: NewsFeedService
    let router: NewsFeedRouter
    let showError: @MainActor (NewsFeedServiceError) -> Void
    lazy var didSelectElementAtIndex: @MainActor (Int) -> Void = { [weak self] index in
        guard let element = self?.newsDataSource.data[index] else { return }
        self?.router.showDetailed(url: element.fullUrl)
    }
    
    @Published var newsDataSource: NewsDataSource = .init(data: [], newData: [])
    var currentPage: UInt = 0
    var loading: Bool = false
    
    init(service: NewsFeedService, router: NewsFeedRouter, showError: @escaping (NewsFeedServiceError) -> Void, currentPage: UInt) {
        self.service = service
        self.router = router
        self.showError = showError
        self.currentPage = currentPage
    }
        
    func getNews() {
        guard !loading else { return }
        loading = true
        
        Task {
            do {
                let news = try await service.getNewsFeed(page: currentPage)
                self.newsDataSource.newData = news
                currentPage += 1
            } catch let error as NewsFeedServiceError {
                await showError(error)
            } catch {
                print(error) // send unknown error through Firebase etc
            }
        }
        
        loading = false
    }
}
