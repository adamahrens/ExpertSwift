import UIKit

struct StructPoint {
  var x: Double
  var y: Double
}

class ClassPoint {
  var x: Double
  var y: Double
  
  init(x: Double, y: Double) {
    (self.x, self.y) = (x, y)
  }
}

// Differences between the Class vs Struct

// 1. Struct has automatic init. Class you have to define. Swift will create the init for the Struct

// 2. Classes are reference semantics. Structs are value semantics. Classes will point to the same instance of memory

let s1 = StructPoint(x: 0, y: 0)
var s2 = s1
s2.x += 10

// p2.x == 10 and p1.x == 0
print("S1.x == \(s1.x), S2.x == \(s2.x)")

let c1 = ClassPoint(x: 0, y: 0)
let c2 = c1
c2.x += 10

// Both xs are 10
print("C1.x == \(c1.x), C2.x == \(c2.x)")

// 3. Scope of mutation. It supports an instance level mutation model. Meaning that in order to manipulate the struct you have to declare it as a var vs let. However, declaring class variables with let still allows mutating them

// You can make a class have value semantics by declaring all their properties as let

// 4. Heap vs Stack. Classes use heap memory structs/enumerations use stack memory. Stack is extremely fast compared to heap. Heap is shared by multiple threads which results in the need for concurrency locks.

// 5. Lifetime & Identity. References have a lifetime so you can definte a deinit function.

// Equatable generates the == functionality for structs. For reference types you have to define the == method

// Code synthesis happenings during the type checking phase of the compiler
struct Point: Equatable {
  var x: Double
  var y: Double
}

extension Point {
  
  static var zero: Point {
    Point(x: 0, y: 0)
  }
  
  static func random(inRadius radius: Double) -> Point {
    guard
      radius >= 0
    else {
      return .zero
    }
    
    let x = Double.random(in: -radius...radius)
    let maxY = (radius * radius - x * x).squareRoot()
    let y = Double.random(in: -maxY...maxY)
    return Point(x: x, y: y)
  }
  
  func flipped() -> Self {
    Point(x: y, y: x)
  }
  
  mutating func flip() {
    self = flipped()
  }
}

struct Size: Equatable {
  var width: Double
  var height: Double
}

struct Rectangle: Equatable {
  var origin: Point
  var size: Size
}

let a = Measurement(value: .pi/2,
                    unit: UnitAngle.radians)

let b = Measurement(value: 90,
                    unit: UnitAngle.degrees)
print(a+b)

struct Email: RawRepresentable {
  var rawValue: String
  
  init?(rawValue: String) {
    guard rawValue.contains("@") else {
      return nil
    }
    self.rawValue = rawValue
  }
}

func send(message: String, to recipient: Email) throws {
  // some implementation
}

// Prefer the init? and add a throws for invalid emails

/*
 Rather than having a property like isValid, it’s better if you can make your custom type’s initializer failable either by returning nil or throwing a more specific error when a valid instance can’t be created. This explicit failure mode allows you to set up your code so the compiler forces you to check for errors. The reward is this: When you write a function that uses a type, you don’t have to worry about half-baked instances that might not be valid
 */

/*
 How many cups are in 1.5 liters? Use Foundation’s Measurement types to figure it out
 */

let cups = Measurement(value: 1.5, unit: UnitVolume.liters).converted(to: .cups)
print("How many cups in 1.5 liters? \(cups)")
