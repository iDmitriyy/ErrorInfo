//
//  OrderedMultipleValuesForKeyStorage+Collection.swift
//  ErrorInfo
//
//  Created by tmp on 05/10/2025.
//

extension OrderedMultipleValuesForKeyStorage: Collection {
  internal var count: Int {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.count
    case .right(let multiValueForKeyDict): multiValueForKeyDict.count
    }
  }
  
  internal var isEmpty: Bool {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.isEmpty
    case .right(let multiValueForKeyDict): multiValueForKeyDict.isEmpty
    }
  }
}

extension OrderedMultipleValuesForKeyStorage: RandomAccessCollection {
  internal var startIndex: Index {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.startIndex
    case .right(let multiValueForKeyDict): multiValueForKeyDict.startIndex
    }
  }
  
  internal var endIndex: Index {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.endIndex
    case .right(let multiValueForKeyDict): multiValueForKeyDict.endIndex
    }
  }
    
  internal subscript(position: Index) -> Element {
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
