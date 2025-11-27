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
  
  internal var keyOrigin: KeyOrigin { .literalConstant }
  
  internal init(uncheckedString: String) {
    rawValue = uncheckedString
  }
}

extension StringLiteralKey: ExpressibleByStringLiteral { // TODO: try to make it zero-cost abstraction
  public typealias StringLiteralType = StaticString
  // TODO: Check if there any costs for usinf StaticString instead of String as literal type.
  // StaticString completely closes the hole when ErronInfoKey can be initialized with dynamically formed string
  // use @const
  public init(stringLiteral value: StaticString) {
    self.rawValue = String(value)
  }
}

extension StringLiteralKey {  
  // TODO: perfomance: borrowing | consuming(copying), @const
  
  public static func + (lhs: Self, rhs: Self) -> Self {
    Self(uncheckedString: lhs.rawValue + "_" + rhs.rawValue)
  }
  
//  public static func & (lhs: Self, rhs: Self) -> Self {
//    Self(uncheckedString: lhs.rawValue + rhs.rawValue)
//  }
//  
//  public static func ^ (lhs: Self, rhs: Self) -> Self {
//    Self(uncheckedString: lhs.rawValue + rhs.rawValue.uppercasingFirstLetter())
//  }
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
