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

@_exported public import protocol SwiftCollectionsNonEmpty.WithCapacityInitializableDictionaryProtocol
@_exported public import protocol SwiftCollectionsNonEmpty.SingleValueSetSubscriptDictionaryProtocol

public protocol DictionaryUnifyingProtocol<Key, Value>: WithCapacityInitializableDictionaryProtocol, SingleValueSetSubscriptDictionaryProtocol {}

extension Dictionary: DictionaryUnifyingProtocol {}
