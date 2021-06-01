import UIKit

typealias Example = (() -> Void)

func run(_ name: String, example: Example) {
  print("\n---- Running \(name) ----")
  example()
  print("---- Completed \(name) ----\n")
}
