/// Sample code from the book, Expert Swift,
/// published at raywenderlich.com, Copyright (c) 2021 Razeware LLC.
/// See LICENSE for details. Thank you for supporting our work!
/// Visit https://www.raywenderlich.com/books/expert-swift

import Foundation
import Combine

final class CurrencyService {
  func getExchangeRate(for currency: Currency) -> AnyPublisher<Decimal, Error> {
    let url = URL(string: "https://api.raywenderlich.com/exchangerates")!
    return URLSession.shared
      .dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: ExchangeResponse.self, decoder: JSONDecoder())
      .map { response -> Decimal in
        guard let rate = response.rates[currency.code] else { fatalError() }
        return rate
      }.eraseToAnyPublisher()
  }
}

private struct ExchangeResponse: Decodable {
  let rates: [String: Decimal]
  let base: String
}
