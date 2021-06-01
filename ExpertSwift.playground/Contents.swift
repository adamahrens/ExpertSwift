import UIKit

typealias Example = (() -> Void)

func run(_ name: String, example: Example) {
  print("\n---- Running \(name) ----")
  example()
  print("---- Completed \(name) ----\n")
}

let numbers = [1, 2, 4, 10, -1, 2, -10]

run("imperative") {
  var total = 0
  numbers.forEach { total += $0 }
  print(total)
}

run("functional") {
    // Allows total to be immutable
  let total = numbers.reduce(0, +)
  print(total)
}

run("functional early exit") {
  let total = numbers.reduce((accumulating: true, total: 0)) { (state, value) in
    if state.accumulating && value >= 0 {
      return (accumulating: true, state.total + value)
    }
    else {
      return (accumulating: false, state.total)
    }
  }.total
  
  print(total)
}

run("imperative early exit") {
  // Total leaks out as a mutable variable
  var total = 0
  for number in numbers {
    guard number >= 0 else { break }
    total += number
  }
  
  print(total)
}

run("imperative early exit JIT mutability") {
  let total: Int = {
    var computedTotal = 0
    for number in numbers {
      guard number >= 0 else { break }
      computedTotal += number
    }
    
    return computedTotal
  }()
  print(total)
}

func ifelse<V>(_ condition: Bool, _ trueValue: V, _ falseValue: V) -> V {
  condition ? trueValue : falseValue
}

run("ifelse implementation") {
  let value = ifelse(.random(), 100, 0)
  print(value)
  
  let otherValue = ifelse(.random(), "TRUE!", "FALSE")
  print(otherValue)
}

// @autoclosure causes the compiler to wrap arguments in a closure automatically
// rethrows. Rethrows propagates the error of any failing closure to the caller. If none of the closure parameters throw,
// @inlinable. This added keyword hints to the compiler that the body of the method should be directly included in the client code without the overhead of calling a function


@inlinable
func ifelseFinal<V>(_ condition: Bool,
               _ valueTrue: @autoclosure () throws -> V,
               _ valueFalse: @autoclosure () throws -> V) rethrows -> V {
  condition ? try valueTrue() : try valueFalse()
}
