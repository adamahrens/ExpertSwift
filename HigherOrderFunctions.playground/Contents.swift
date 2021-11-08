import UIKit

protocol ParagraphFormatter {
  func format(paragraph: String) -> String
}

final class SimpleFormatter: ParagraphFormatter {
  func format(paragraph: String) -> String {
    guard !paragraph.isEmpty else { return paragraph }
    var formatted = paragraph.prefix(1).uppercased() + paragraph.dropFirst()
    if let lastCharacter = formatted.last, !lastCharacter.isPunctuation {
      formatted += "."
    }
    
    return formatted
  }
}

final class TextPrinter {
  let formatter: ParagraphFormatter
  
  init(formatter: ParagraphFormatter) {
    self.formatter = formatter
  }
  
  func printOff(paragraphs: [String]) {
    for paragraph in paragraphs {
      let formatted = formatter.format(paragraph: paragraph)
      print(formatted)
    }
  }
}

// Testing
let simpleFormatter = SimpleFormatter()
let printer = TextPrinter(formatter: simpleFormatter)
let examples = ["basic text example", "Another text example!!", "one more text example"]
printer.printOff(paragraphs: examples)

// Add first order to arrays

extension Array where Element == String {
  func printFormatted(formatter: ParagraphFormatter) {
    let printer = TextPrinter(formatter: formatter)
    printer.printOff(paragraphs: self)
  }
}

examples.printFormatted(formatter: simpleFormatter)


/// Not terribly swifty. Lets make a higher order function

func format(paragraph: String) -> String {
  guard !paragraph.isEmpty else { return paragraph }
  var formatted = paragraph.prefix(1).uppercased() + paragraph.dropFirst()
  if let lastCharacter = formatted.last, !lastCharacter.isPunctuation {
    formatted += "."
  }
  
  return formatted
}

extension Array where Element == String {
  func printFormatted(formatter: ((String) -> String)) {
    for string in self {
      print(formatter(string))
    }
  }
}

examples.printFormatted(formatter: format(paragraph:))

/// Map

let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
let mapped = numbers.map { $0 * $0 }
print(mapped)


/// CompactMap
func wordsToInt(_ string: String) -> Int? {
  let formatter = NumberFormatter()
  formatter.numberStyle = .spellOut
  return formatter.number(from: string.lowercased()) as? Int
}

print(wordsToInt("Three"))
print(wordsToInt("twenty-five"))

extension Int {
  func word() -> String? {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    return formatter.string(from: self as NSNumber)
  }
}

print(3.word())
print(25.word())
print(101.word())
print(Int.word)
print(Int.word(35)())
