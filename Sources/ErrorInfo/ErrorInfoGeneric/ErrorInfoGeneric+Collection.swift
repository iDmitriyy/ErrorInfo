//
//  ErrorInfoGeneric+Collection.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

extension ErrorInfoGeneric: Collection {
  @inlinable
  @inline(__always)
  public var count: Int {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.count
    case .right(let multiValueForKeyDict): multiValueForKeyDict.count
    }
  }
  
  @inlinable
  @inline(__always)
  public var isEmpty: Bool {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.isEmpty
    case .right(let multiValueForKeyDict): multiValueForKeyDict.isEmpty
    }
  }
}

extension ErrorInfoGeneric: RandomAccessCollection {
  @inlinable
  public var startIndex: Int {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.startIndex
    case .right(let multiValueForKeyDict): multiValueForKeyDict.startIndex
    }
  }
  
  @inlinable
  public var endIndex: Int {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.endIndex
    case .right(let multiValueForKeyDict): multiValueForKeyDict.endIndex
    }
  }
  
  @inlinable
  @inline(__always)
  public subscript(position: Int) -> Element {
    switch _variant {
    case .left(let singleValueForKeyDict):
      let (key, value) = singleValueForKeyDict[position]
      return (key, AnnotatedRecord.value(value))
    case .right(let multiValueForKeyDict):
      let (key, wrappedValue) = multiValueForKeyDict[position]
      return (key, wrappedValue)
    }
  }
}

//extension ErrorInfoGeneric {
//  /// Returns a Boolean value indicating whether the sequence contains values for a given key that satisfies the given predicate.
//  internal func containsValues<E>(forKey key: Key, where predicate: (Value) throws(E) -> Bool) rethrows -> Bool {
//    switch _variant {
//    case .left(let singleValueForKeyDict):
//      guard let value = singleValueForKeyDict[key] else { return false }
//      return try predicate(value)
//      
//    case .right(let multiValueForKeyDict):
//      return try multiValueForKeyDict.containsValues(forKey: key, where: { wrappedValue in
//        try predicate(wrappedValue.record)
//      })
//    }
//  }
//}
