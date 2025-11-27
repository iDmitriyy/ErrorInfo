//
//  ErronInfoLiteralKey.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

public struct StringLiteralKey: Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
  /// A new instance initialized with `rawValue` will be equivalent to this instance.
  internal let rawValue: String
  
  public var description: String { rawValue }
  
  public var debugDescription: String { rawValue } // TODO: ? rawValue.debugDescription
  
  internal let keyOrigin: KeyOrigin
  
  internal init(_combinedLiteralsString: String) {
    rawValue = _combinedLiteralsString
    keyOrigin = .combinedLiterals
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(rawValue)
  }
  
  public static func == (lhs: StringLiteralKey, rhs: StringLiteralKey) -> Bool {
    lhs.rawValue == rhs.rawValue
  }
}

extension StringLiteralKey: ExpressibleByStringLiteral { // TODO: try to make it zero-cost abstraction
  public typealias StringLiteralType = StaticString
  // TODO: Check if there any costs for usinf StaticString instead of String as literal type.
  // StaticString completely closes the hole when ErronInfoKey can be initialized with dynamically formed string
  // use @const
  public init(stringLiteral value: StaticString) {
    self.rawValue = String(value)
    self.keyOrigin = .literalConstant
  }
}

extension StringLiteralKey {  
  // TODO: perfomance: borrowing | consuming(copying), @const
  
  public static func + (lhs: Self, rhs: Self) -> Self {
    Self(_combinedLiteralsString: lhs.rawValue + "_" + rhs.rawValue)
  }
  
//  public static func & (lhs: Self, rhs: Self) -> Self {
//    Self(uncheckedString: lhs.rawValue + rhs.rawValue)
//  }
//  
//  public static func ^ (lhs: Self, rhs: Self) -> Self {
//    Self(uncheckedString: lhs.rawValue + rhs.rawValue.uppercasingFirstLetter())
//  }
}
