import Combine
import Foundation
import PlaygroundSupport

PlaygroundSupport.PlaygroundPage.current.needsIndefiniteExecution = true

func run(_ name: String, action: () -> Void) {
  print("--- Start \(name) ---")
  action()
  print("--- End \(name) ---")
}

// Codable provides Decoding/Encoding.
struct Todo: Codable {
  let userId: Int
  let id: Int
  let title: String
  let completed: Bool
}

var subscriptions = Set<AnyCancellable>()


run("dataTaskPublisher") {
  guard
    let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")
  else { return }
  
  URLSession.shared.dataTaskPublisher(for: url).sink { completion in
    if case let .failure(error) = completion {
      print("Unable to retrieve Todo data. \(error)")
    }
  } receiveValue: { data, response in
    if let res = response as? HTTPURLResponse {
      print("Data size \(data.count). Response Code \(res.statusCode)")
    }
  }.store(in: &subscriptions)
}

run("dataTaskPublisher with decode") {
  guard
    let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")
  else { return }
  
  URLSession.shared.dataTaskPublisher(for: url)
    .tryMap { data, _ in
      try JSONDecoder().decode(Todo.self, from: data)
    }.sink { completion in
      if case let .failure(error) = completion {
        print("Unable to retrieve Todo data. \(error)")
      }
    } receiveValue: { todo in
      print("Got \(todo)")
    }.store(in: &subscriptions)
}

run("dataTaskPublisher with upstream decoding") {
  guard
    let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")
  else { return }
  
  URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: Todo.self, decoder: JSONDecoder())
    .sink { completion in
      if case let .failure(error) = completion {
        print("Unable to retrieve Todo data. \(error)")
      }
    } receiveValue: { todo in
      print("Got \(todo)")
    }.store(in: &subscriptions)
}

// Sharing a publisher allows to relay values to future subscribers
// Great for future subscribers not caring about data emitted before connected
run("Sharing") {
  let rayWenderlichUrl = URL(string: "https://www.raywenderlich.com")!
  let shared = URLSession.shared.dataTaskPublisher(for: rayWenderlichUrl)
    .map(\.data)
    .print("shared!!!!")
    .share()
  
  shared.sink { _ in } receiveValue: {  print("sub1 receiveValue \($0)") }.store(in: &subscriptions)
  shared.sink { _ in } receiveValue: {  print("sub2 receiveValue \($0)") }.store(in: &subscriptions)
}

// Use multicast if you want Publisher to wait for all subscribers are setup before
run("Sharing") {
  let rayWenderlichUrl = URL(string: "https://www.raywenderlich.com")!
  
  let subject = PassthroughSubject<Data, URLError>()
  
  let multicast = URLSession.shared.dataTaskPublisher(for: rayWenderlichUrl)
    .map(\.data)
    .print("multi!!!!")
    .multicast(subject: subject)
  
  multicast.sink { _ in } receiveValue: {  print("mult1 receiveValue \($0)") }.store(in: &subscriptions)
  multicast.sink { _ in } receiveValue: {  print("mult2 receiveValue \($0)") }.store(in: &subscriptions)
  multicast.connect()
  
  subject.send(Data())
}


// Managing Backpressure. request method to control demand
// Allows dymanic managing of backpressure. New max are added to current max. Can only be postive

run("Backpressure") {
  final class IntSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = Never

    func receive(subscription: Subscription) {
      subscription.request(.max(2))
    }
    
    func receive(_ input: Int) -> Subscribers.Demand {
      print("Received value \(input)")
      
      switch input {
        case 1:
          return .max(2)
        case 3:
          return .max(1)
        default:
          return .none
      }
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
      print("Received completion")
    }
  }
  
  
  let sub = IntSubscriber()
  let subject = PassthroughSubject<Int, Never>()
  subject.subscribe(sub)
  
  subject.send(1)
  subject.send(2)
  subject.send(3)
  subject.send(4)
  subject.send(5)
  
  // Max starts at 2, when it hits 1 max(2) is added to original so 4.
  // When it sends 3 it adds max(1) so total of 5. Everything else is skipped then
  subject.send(6)
  subject.send(7)
  subject.send(8)
  subject.send(9)
}

// Mapping errors
// tryMap erases error to standard Swift.error
// map returns customer error

run("map vs tryMap for errors") {
  
  enum NameError: Error {
    case tooShort(String)
    case invalid
  }
  
  Just("Adam")
    .setFailureType(to: NameError.self)
    .map { $0 + " Ahrens" }
    .sink { completion in
      switch completion {
        case .finished :
          print("Error example finished")
        case .failure(.invalid):
          print("Got error invalid")
        case .failure(.tooShort(let message)):
          print("Got error name too short. \(message)")
      }
    } receiveValue: { value in
      print("Error example receieved \(value)")
    }.store(in: &subscriptions)
  
  Just("Hello")
    .setFailureType(to: NameError.self)
    .tryMap { throw NameError.tooShort($0) }
    .mapError { $0 as? NameError ?? .invalid}
    .sink { completion in
      switch completion {
        case .finished :
          print("Error example finished")
        case .failure(.invalid):
          print("Got error invalid")
        case .failure(.tooShort(let message)):
          print("Got error name too short. \(message)")
      }
    } receiveValue: { value in
      print("Error example receieved \(value)")
    }.store(in: &subscriptions)
}

// If a publisher errors can use retry
// Add a handleEvents calls to see when receiveSubscripton and receiveCompletion events occur
// Just add a .retry(numOfTimes)
// Use replaceError() to give a default value
// Use catch and potentially call another service


// Testing combine operators

