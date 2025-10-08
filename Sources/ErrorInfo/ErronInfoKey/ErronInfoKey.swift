//
//  ErronInfoKey.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

public struct ErronInfoKey: Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {  
  /// A new instance initialized with `rawValue` will be equivalent to this instance.
  public let rawValue: String
  
  public var description: String { rawValue }
  
  public var debugDescription: String { rawValue }
    
  internal init(uncheckedString: String) {
    rawValue = uncheckedString
  }
}

extension ErronInfoKey: ExpressibleByStringLiteral { // TODO: try to make it zero-cost abstraction
  public typealias StringLiteralType = StaticString
  // TODO: Check if there any costs for usinf StaticString instead of String as literal type.
  // StaticString completely closes the hole when ErronInfoKey can be initialized with dynamically formed string
  // use @const
  public init(stringLiteral value: StaticString) {
    self.rawValue = String.init(value)
  }
}

extension ErronInfoKey {
  public func withPrefix(_ prefix: Self) -> Self {
    Self(uncheckedString: prefix.rawValue + rawValue)
  }
  
  public func withSuffix(_ suffix: Self) -> Self {
    Self(uncheckedString: rawValue + suffix.rawValue)
  }
  
  // TODO: perfomance: borrowing | consuming(copying), @const
  public static func + (lhs: Self, rhs: Self) -> Self {
    Self(uncheckedString: lhs.rawValue + rhs.rawValue)
  }
}

// TODO: add + - operators for Self.

// extension ErronInfoKey {
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
// extension ErronInfoKey.Separator {
//  public static let dash = Self(uncheckedString: "-")
// }
