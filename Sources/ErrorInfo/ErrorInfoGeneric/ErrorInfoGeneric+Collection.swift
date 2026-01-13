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
  
  public func countValues(where predicate: (RecordValue) -> Bool) -> Int {
    switch _variant {
    case .left(let singleValueForKeyDict):
      singleValueForKeyDict.values.count(where: { predicate($0.someValue) })
    case .right(let multiValueForKeyDict):
      multiValueForKeyDict._entries.count(where: { predicate($0.value.record.someValue) })
    }
  }
}

extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentable {
  public var valuesCount: Int {
    countValues(where: { $0.isValue })
  }
}
