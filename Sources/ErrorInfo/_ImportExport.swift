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


//@_exported public import protocol SwiftCollectionsNonEmpty.EmptyInitializableWithCapacityDictionary
//@_exported public import protocol SwiftCollectionsNonEmpty.SingleValueSetSubscriptDictionary

@_exported public import protocol GeneralizedCollections.DictionaryProtocol
@_exported public import protocol GeneralizedCollections.EmptyInitializableWithCapacityDictionary

// MARK: - @retroactive

public import protocol InternalCollectionsUtilities._UniqueCollection

extension AnyCollection: @retroactive _UniqueCollection {}


internal import typealias NonEmpty.NonEmptyString

extension NonEmptyString {
  init(element: Character) {
    self.init(element)
  }
}
