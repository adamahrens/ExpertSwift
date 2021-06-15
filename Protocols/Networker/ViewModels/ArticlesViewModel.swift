/// Sample code from the book, Expert Swift,
/// published at raywenderlich.com, Copyright (c) 2021 Razeware LLC.
/// See LICENSE for details. Thank you for supporting our work!
/// Visit https://www.raywenderlich.com/books/expert-swift

import SwiftUI
import Combine

final class ArticlesViewModel: ObservableObject {
  @Published private(set) var articles = [Article]()

  private var cancellables = Set<AnyCancellable>()
  private var networker: Networking
  
  init(network: Networking) {
    networker = network
    self.networker.delegate = self
  }

  func fetchArticles() {
    let request = ArticleRequest()
//    Before Protocol
//    let decoder = JSONDecoder()
//
//    networker
//      .fetch(request)
//      .decode(type: Articles.self, decoder: decoder)
//      .map { $0.data.map { $0.article } }
//      .replaceError(with: [])
//      .receive(on: DispatchQueue.main)
//      .assign(to: \.articles, on: self)
//      .store(in: &cancellables)
    
    networker
      .fetch(request)
      .tryMap([Article].init) // Uses the protocol to decode to an array of articles
      .replaceError(with: [])
      .receive(on: DispatchQueue.main)
      .assign(to: \.articles, on: self)
      .store(in: &cancellables)
  }

  func fetchImage(for article: Article) {
    guard
      article.downloadedImage == nil,
      let articleIndex = articles.firstIndex(where: { $0.id == article.id })
    else { return }
    
    let request = ImageRequest(url: article.image)
    networker
      .fetch(request)
      .map(UIImage.init)
      .receive(on: DispatchQueue.main)
      .sink { _ in
      } receiveValue: { [weak self] image in
        self?.articles[articleIndex].downloadedImage = image
      }
      .store(in: &cancellables)
  }
}

extension ArticlesViewModel: NetworkingDelegate {
  func headers(for networking: Networking) -> [String : String] {
    ["Content-Type" : "application/wnd.api+json; charset=utf-8"]
  }
  
  func networking(_ networking: Networking, transform publisher: AnyPublisher<Data, URLError>) -> AnyPublisher<Data, URLError> {
    publisher.receive(on: DispatchQueue.main).eraseToAnyPublisher()
  }
}
