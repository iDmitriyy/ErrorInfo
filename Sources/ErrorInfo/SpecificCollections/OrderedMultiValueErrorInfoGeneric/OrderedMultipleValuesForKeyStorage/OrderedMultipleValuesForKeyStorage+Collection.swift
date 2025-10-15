//
//  OrderedMultipleValuesForKeyStorage+Collection.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 05/10/2025.
//

extension OrderedMultipleValuesForKeyStorage: Collection {
  @inlinable internal var count: Int {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.count
    case .right(let multiValueForKeyDict): multiValueForKeyDict.count
    }
  }
  
  @inlinable internal var isEmpty: Bool {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.isEmpty
    case .right(let multiValueForKeyDict): multiValueForKeyDict.isEmpty
    }
  }
}

extension OrderedMultipleValuesForKeyStorage: RandomAccessCollection {
  @inlinable internal var startIndex: Index {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.startIndex
    case .right(let multiValueForKeyDict): multiValueForKeyDict.startIndex
    }
  }
  
  @inlinable internal var endIndex: Index {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.endIndex
    case .right(let multiValueForKeyDict): multiValueForKeyDict.endIndex
    }
  }
    
  @inlinable internal subscript(position: Index) -> Element {
    switch _variant {
    case .left(let singleValueForKeyDict):
      let (key, value) = singleValueForKeyDict[position]
      return (key, WrappedValue.value(value))
    case .right(let multiValueForKeyDict):
      let (key, wrappedValue) = multiValueForKeyDict[position]
      return (key, wrappedValue)
    }
  }
}

extension OrderedMultipleValuesForKeyStorage {
  /// Returns a Boolean value indicating whether the sequence contains valuess for a given key that satisfies the given predicate.
  internal func containsValues<E>(forKey key: Key, where predicate: (Value) throws(E) -> Bool) rethrows -> Bool {
    switch _variant {
    case .left(let singleValueForKeyDict):
      guard let value = singleValueForKeyDict[key] else { return false }
      return try predicate(value)
      
    case .right(let multiValueForKeyDict):
      return try multiValueForKeyDict.containsValues(forKey: key, where: { warppedValue in
        try predicate(warppedValue.value)
      })
    }
  }
}
