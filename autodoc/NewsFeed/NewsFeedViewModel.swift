//
//  NewsFeedViewModel.swift
//  autodoc
//
//  Created by Артём Зайцев on 08.04.2025.
//
import Combine
import Foundation

final class NewsFeedViewModel {
    let service: NewsFeedService
    let router: NewsFeedRouter
    let showError: @MainActor (NewsFeedServiceError) -> Void
    lazy var didSelectElementAtIndex: @MainActor (Int) -> Void = { [weak self] index in
        guard let element = self?.data[index] else { return }
        // TODO: provide image urls
        let urls: [URL] = {
            var absoluteStrings: [String] = []
            for i in 1 ..< 24 {
                absoluteStrings.append("https://file.autodoc.ru/news/avto-novosti/2854777875_\(i).jpg")
            }
            return absoluteStrings.compactMap { URL(string: $0) }
        }()
        let subtitle: String = "Производитель оставляет за собой право вносить изменения в конструкцию изделий"
        
        self?.router.showGallery(imageURLs: urls, subtitle: subtitle)
//        self?.router.showGallery(imageURLs: urls, subtitle: nil)
    }
    
    @Published var data: [NewsFeedElement] = []
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
                self.data = [self.data + news].flatMap { $0 }.reduce(into: []) { (partialResult: inout [NewsFeedElement], value: NewsFeedElement) in
                    /// На всякий случай перестрахуемся от одинакового id новости и проигнорируем её
                    /// если такое вдруг прийдёт с бэка
                    guard !partialResult.contains(where: { $0.id == value.id }) else { return }
                    partialResult.append(value)
                }
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
