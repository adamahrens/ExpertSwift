import UIKit

enum Language {
  case english, german, french
}

protocol Localizable {
  static var supportedLanguages: [Language] { get }
}

// Inherits the supportedLanguages requirement above
protocol ImmutableLocalizable: Localizable {
  func changed(to language: Language) -> Self
}

// Mutating is used for structs
protocol MutableLocalizable: Localizable {
  mutating func change(to language: Language)
}

struct Text: ImmutableLocalizable {
  var text = ""
  
  func changed(to language: Language) -> Text {
    switch language {
      case .english:
        return Text(text: "Hello World")
      case .german:
        return Text(text: "Hallo Welt")
      case .french:
        return Text(text: "Bonjour le monde")
    }
  }
  
  static let supportedLanguages: [Language] = [.english, .german]
}

// Can extend classes and structs we didn't create

extension UILabel: MutableLocalizable {
  
  static let supportedLanguages: [Language] = [.english, .german]
  
  func change(to language: Language) {
    switch language {
      case .english:
        text = "Hello World"
      case .german:
        text = "Hallo Welt"
      case .french:
        text = "Bonjour le monde"
    }
  }
}

// Can set defaults on a Protocol extension
extension Localizable {
  static var supportedLanguages: [Language] {
    return [.english]
  }
}

struct Image: Localizable {
  // Get the default supportedLanguages above
}

protocol ErrorMessageDisplayable where Self: UIViewController {
  func display(error: Error)
}

extension UIViewController: ErrorMessageDisplayable {
  func display(error: Error) {
    let controller = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
    let dismiss = UIAlertAction(title: "Ok", style: .destructive)
    controller.addAction(dismiss)
    present(controller, animated: true)
  }
}

// Won't work since ErrorMessageDisplayable constrainted to be a type of UIViewController
// struct Input: ErrorMessageDisplayable


// 2 mechanims for storing/call functions. Static vs Dynamic Dispatch
// With static when a function won't change. Used for globabl functions, methods in structs, and methods in final marked classes
// Compiler can hardcode the function address since it won't be changing.
// Dynamic makes inheritance/protocols work. Each class gets a table of address/function calls. Children can override though. Therefore Dynamic has a lookup cost. In the above if we pass around a Localizable param to a method or class. Swift doesn't know if it's Image or Text. It has to do that an runtime.

protocol Greetable {
  func greet() -> String
}

extension Greetable {
  func greet() -> String {
    return "Hello"
  }
  
  // A method in the protocl extension that isn't a requirement can be can unwanted behaviors
  func leave() -> String {
    return "Good Bye"
  }
}

struct GermanGreeter: Greetable {
  func greet() -> String {
    return "Hallo"
  }
  
  func leave() -> String {
    return "Tschuss"
  }
}

let germanGreeter = GermanGreeter()
print(germanGreeter.leave())


// Existential Type (Basically think of a it as a placeholder for a real concrete type)
let genericGreeter: Greetable = GermanGreeter()
print(genericGreeter.leave())

// Requiring multiple protocol requirements in a function
func localizedGreeting(with greeter: Greetable & Localizable) {
  
}
