//
//  NewsFeedService.swift
//  autodoc
//
//  Created by Артём Зайцев on 08.04.2025.
//


import Foundation

public struct NewsFeedElement: Codable {
    /// "id": 8418,
    /// "title": "Новая модификация Maserati GranCabrio",
    /// "description": "Maserati представила начальную версию GranCabrio",
    /// "publishedDate": "2025-02-25T00:00:00",
    /// "url": "avto-novosti/maserati_gran_cabrio",
    /// "fullUrl": "https://www.autodoc.ru/avto-novosti/maserati_gran_cabrio",
    /// "titleImageUrl": "https://file.autodoc.ru/news/avto-novosti/2246340624_1.jpg",
    /// "categoryType": "Автомобильные новости"
    
    let id: Int
    let title: String
    let description: String
    let publishedDate: Date?
    let url: URL
    let fullUrl: URL
    let titleImageUrl: URL
    let categoryType: String
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        let publishedDateString = try container.decode(String.self, forKey: .publishedDate)
        let formatter = DateFormatter.iso8601NoTimezone()
        let date = formatter.date(from: publishedDateString)
        self.publishedDate = date
        self.url = try container.decode(URL.self, forKey: .url)
        self.fullUrl = try container.decode(URL.self, forKey: .fullUrl)
        self.titleImageUrl = try container.decode(URL.self, forKey: .titleImageUrl)
        self.categoryType = try container.decode(String.self, forKey: .categoryType)
    }
}

public enum NewsFeedServiceError: Error {
    case urlCorrupted
    case custom(String)
}

public protocol NewsFeedServiceProtocol {
    /// https://webapi.autodoc.ru/api/news/1/15 [1 - страница, 15 - количество элементов]
    func getNewsFeed(page: UInt, elements: UInt) async throws -> [NewsFeedElement]
}

final class NewsFeedService: NewsFeedServiceProtocol {
    struct Paths {
        let feed: String
    }
    
    let base: String
    let paths: Paths
    
    init(base: String, paths: Paths) {
        self.base = base
        self.paths = paths
    }
    
    func getNewsFeed(page: UInt, elements: UInt = 15) async throws -> [NewsFeedElement] {
        guard let url = URL(string: base + paths.feed + "\\\(page)" + "\\\(elements)") else { throw NewsFeedServiceError.urlCorrupted }
        let request = URLRequest(url: url)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let response = try decoder.decode(NewsFeedResponse.self, from: data)
            return response.news
        } catch {
            throw NewsFeedServiceError.custom("Error, getting news feed: \(error.localizedDescription)")
        }
    }
}

fileprivate struct NewsFeedResponse: Decodable {
    let news: [NewsFeedElement]
    let totalCount: Int
}

fileprivate extension DateFormatter {
    static func iso8601NoTimezone() -> DateFormatter {
        let dateFormatter = DateFormatter()
        // 2025-03-20T00:00:00
        dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
        return dateFormatter
    }
}
