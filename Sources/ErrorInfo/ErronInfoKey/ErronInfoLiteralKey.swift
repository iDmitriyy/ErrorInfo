//
//  ErronInfoLiteralKey.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

public struct ErronInfoLiteralKey: Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {  
  /// A new instance initialized with `rawValue` will be equivalent to this instance.
  internal let rawValue: String
  
  public var description: String { rawValue }
  
  public var debugDescription: String { rawValue } // TODO: ? rawValue.debugDescription
    
  internal init(uncheckedString: String) {
    rawValue = uncheckedString
  }
}

extension ErronInfoLiteralKey: ExpressibleByStringLiteral { // TODO: try to make it zero-cost abstraction
  public typealias StringLiteralType = StaticString
  // TODO: Check if there any costs for usinf StaticString instead of String as literal type.
  // StaticString completely closes the hole when ErronInfoKey can be initialized with dynamically formed string
  // use @const
  public init(stringLiteral value: StaticString) {
    self.rawValue = String(value)
  }
}

extension ErronInfoLiteralKey {
//  public func withPrefix(_ prefix: Self) -> Self {
//    Self(uncheckedString: prefix.rawValue + rawValue)
//  }
//  
//  public func withSuffix(_ suffix: Self) -> Self {
//    Self(uncheckedString: rawValue + suffix.rawValue)
//  }
  
  // TODO: perfomance: borrowing | consuming(copying), @const
  public static func + (lhs: Self, rhs: Self) -> Self {
    Self(uncheckedString: lhs.rawValue + rhs.rawValue)
  }
  
  public static func + (lhs: Self, rhs: StaticString) -> Self {
    Self(uncheckedString: lhs.rawValue + String(rhs))
  }
  
  public static func + (lhs: StaticString, rhs: Self) -> Self {
    Self(uncheckedString: String(lhs) + rhs.rawValue)
  }
}

// TODO: add + - operators for Self.

// extension ErronInfoLiteralKey {
//  public struct Separator: Sendable, Hashable, CustomStringConvertible { // RawRepresentable
//    private let rawValue: String
//
//    public var description: String { rawValue }
//
//    init(uncheckedString: String) {
//      self.rawValue = uncheckedString
//    }
//  }
// }
//
// extension ErronInfoLiteralKey.Separator {
//  public static let dash = Self(uncheckedString: "-")
// }
