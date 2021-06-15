/// Sample code from the book, Expert Swift,
/// published at raywenderlich.com, Copyright (c) 2021 Razeware LLC.
/// See LICENSE for details. Thank you for supporting our work!
/// Visit https://www.raywenderlich.com/books/expert-swift

import XCTest
import Combine
@testable import Networker

class ArticlesViewModelTests: XCTestCase {
  // swiftlint:disable:next implicitly_unwrapped_optional
  var viewModel: ArticlesViewModel!
  var cancellables: Set<AnyCancellable> = []

  override func setUpWithError() throws {
    try super.setUpWithError()
    
    viewModel = ArticlesViewModel(network: MockNetworker())
  }

  func testArticlesAreFetchedCorrectly() {
    XCTAssert(viewModel.articles.isEmpty)
    
    let expectation = XCTestExpectation(description: "Articles fetched from network")
    
    viewModel.$articles.sink { articles in
      guard
        !articles.isEmpty
      else { return }
      
      XCTAssertEqual(articles[0].id, "123456")
      expectation.fulfill()
    }
    .store(in: &cancellables)
    
    viewModel.fetchArticles()
    wait(for: [expectation], timeout: 1.0)
  }
}

final class MockNetworker: Networking {
  
  weak var delegate: NetworkingDelegate?
  
  func fetch(_ request: Request) -> AnyPublisher<Data, URLError> {
    let article = Article(name: "Name", description: "Description", image: URL(string: "https://image.com")!, id: "123456", downloadedImage: nil)
    let data = ArticleData(article: article)
    let articles = Articles(data: [data])
    let outputData = try! JSONEncoder().encode(articles)
    
    return Just<Data>(outputData)
      .setFailureType(to: URLError.self)
      .eraseToAnyPublisher()
  }
}
