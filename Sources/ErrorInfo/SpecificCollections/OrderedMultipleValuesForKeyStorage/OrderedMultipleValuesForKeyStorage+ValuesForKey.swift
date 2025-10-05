//
//  OrderedMultipleValuesForKeyStorage+ValuesForKey.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 05/10/2025.
//

internal import enum SwiftyKit.Either
@_spi(GeneralizedCollections) private import struct GeneralizedCollections.IterationDeferredMapSequence

extension OrderedMultipleValuesForKeyStorage {
  // TODO: NonEmpty ValuesForKeySlice | NonEmpty sequence
  internal struct ValuesForKeySlice: Sequence { // TODO: ~Escapaable
    internal typealias Element = WrappedValue
    
    // TODO: AnySequence<Value> used becuase multiValueForKeyDict return opaque type for `allValues(forKey:)`
    private let _source: Either<AnySequence<Element>, AnySequence<Element>>
    
    internal init?(_variant: Variant, key: Key) {
      switch _variant {
      case .left(let singleValueForKeyDict):
        guard let value = singleValueForKeyDict[key] else { return nil }
        let collectionOfOne = CollectionOfOne(value)
        let adapter = IterationDeferredMapSequence(sequence: collectionOfOne, transform: { WrappedValue.value($0) })
        _source = .left(AnySequence(adapter))
      case .right(let multiValueForKeyDict):
        guard let allValuesForKey = multiValueForKeyDict.allValuesView(forKey: key) else { return nil }
        _source = .right(AnySequence(allValuesForKey))
      }
    }
    
    internal func makeIterator() -> some IteratorProtocol<Element> {
      switch _source {
      case .left(let sequence): sequence.makeIterator()
      case .right(let sequence): sequence.makeIterator()
      }
    }
  }
}
