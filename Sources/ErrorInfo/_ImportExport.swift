//
//  _ImportExport.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

// import for all files:

//@_exported public import protocol IndependentDeclarations.Namespacing
//@_exported public import protocol IndependentDeclarations.DictionaryUnifyingProtocol
//@_exported public import struct IndependentDeclarations.StaticFileLine

// @_exported public import StdLibExtensions // TODO: remove and import privately?

@_exported public import struct SwiftyKit.StaticFileLine


@_exported public import protocol SwiftCollectionsNonEmpty.EmptyInitializableWithCapacityDictionary
@_exported public import protocol SwiftCollectionsNonEmpty.SingleValueSetSubscriptDictionary

public protocol DictionaryUnifyingProtocol<Key, Value>: EmptyInitializableWithCapacityDictionary, SingleValueSetSubscriptDictionary {}

extension Dictionary: DictionaryUnifyingProtocol {}

public import struct OrderedCollections.OrderedDictionary

extension OrderedDictionary: DictionaryUnifyingProtocol {}

extension DictionaryUnifyingProtocol {
  @inlinable
  public func hasValue(forKey key: Key) -> Bool {
    // TODO: inspect which is faster – key.contain or index(forKey: key)
    // @specialize – choose most perfomant execution path for each specialization, if found
    // Self: Dictionary | OrderedDictionary
    // Key: String | ?Int
    // Value: -
    
    // keys.contains(key)
    // index(forKey: key) != nil
    return false
  }
}

internal import typealias NonEmpty.NonEmptyString

extension NonEmptyString {
  init(element: Element) {
    fatalError()
  }
}
