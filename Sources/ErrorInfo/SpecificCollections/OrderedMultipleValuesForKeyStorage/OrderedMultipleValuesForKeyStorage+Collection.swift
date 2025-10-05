//
//  OrderedMultipleValuesForKeyStorage+Collection.swift
//  ErrorInfo
//
//  Created by tmp on 05/10/2025.
//

extension OrderedMultipleValuesForKeyStorage: Collection {
  public var count: Int {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.count
    case .right(let multiValueForKeyDict): multiValueForKeyDict.count
    }
  }
  
  public var isEmpty: Bool {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.isEmpty
    case .right(let multiValueForKeyDict): multiValueForKeyDict.isEmpty
    }
  }
}

extension OrderedMultipleValuesForKeyStorage: RandomAccessCollection {
  public var startIndex: Int {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.startIndex
    case .right(let multiValueForKeyDict): multiValueForKeyDict.startIndex
    }
  }
  
  public var endIndex: Int {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.endIndex
    case .right(let multiValueForKeyDict): multiValueForKeyDict.endIndex
    }
  }
    
  public subscript(position: Int) -> Element {
    switch _variant {
    case .left(let singleValueForKeyDict):
      // return singleValueForKeyDict[position]
      fatalError()
    case .right(let multiValueForKeyDict):
      // let (key, valueWrapper) = multiValueForKeyDict[position]
      // return (key, valueWrapper.value)
      fatalError()
    }
  }
}
