//
//  OrderedMultipleValuesForKeyStorage+ValuesForKey.swift
//  ErrorInfo
//
//  Created by tmp on 05/10/2025.
//

internal import enum SwiftyKit.Either

extension OrderedMultipleValuesForKeyStorage {
  internal struct ValuesForKeySlice: Sequence { // TODO: ~Escapaable
    internal typealias Element = Value
    
    // TODO: AnySequence<Value> used becuase multiValueForKeyDict return opaque type for `allValues(forKey:)`
    private let _source: Either<CollectionOfOne<Value>, AnySequence<Value>>
    
    internal init?(_variant: Variant, key: Key) {
      switch _variant {
      case .left(let singleValueForKeyDict):
        guard let value = singleValueForKeyDict[key] else { return nil }
        _source = .left(CollectionOfOne(value))
      case .right(let multiValueForKeyDict):
        guard let allValuesForKey = multiValueForKeyDict.allValuesView(forKey: key) else { return nil }
        _source = .right(AnySequence(allValuesForKey))
      }
    }
    
    internal func makeIterator() -> some IteratorProtocol<Value> {
      
    }
  }
}
