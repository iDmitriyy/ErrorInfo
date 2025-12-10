//
//  OrderedMultipleValuesForKeyStorage+ValuesForKeySlice.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 05/10/2025.
//

extension OrderedMultipleValuesForKeyStorage {
  // TODO: NonEmpty ValuesForKeySlice | NonEmpty sequence
  internal struct ValuesForKeySlice: Sequence { // TODO: ~Escapaable
    internal typealias Element = TaggedValue
    
    // TODO: AnySequence<Value> used becuase multiValueForKeyDict return opaque type for `allValues(forKey:)`
    private let _source: Either<AnySequence<Element>, AnySequence<Element>>
    
    internal init?(_variant: Variant, key: Key) {
      switch _variant {
      case .left(let singleValueForKeyDict):
        guard let value = singleValueForKeyDict[key] else { return nil }
        let collectionOfOne = CollectionOfOne(value)
        let adapter = collectionOfOne.lazy.map(TaggedValue.value)
        _source = .left(AnySequence(adapter))
      case .right(let multiValueForKeyDict):
        guard let allValuesForKey = multiValueForKeyDict.allValuesSlice(forKey: key) else { return nil }
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
