//
//  _ImportExport.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

// import for all files:

@_exported public import struct OrderedCollections.OrderedDictionary
@_exported public import typealias NonEmpty.NonEmptyArray

@_exported public import protocol GeneralizedCollections.DictionaryProtocol
@_exported public import protocol GeneralizedCollections.EmptyInitializableWithCapacityDictionary

// MARK: - @retroactive

public import protocol InternalCollectionsUtilities._UniqueCollection

extension AnyCollection: @retroactive _UniqueCollection {}

import typealias NonEmpty.NonEmptyString

extension NonEmptyString {
  internal init(element: Character) {
    self.init(element)
  }
}
