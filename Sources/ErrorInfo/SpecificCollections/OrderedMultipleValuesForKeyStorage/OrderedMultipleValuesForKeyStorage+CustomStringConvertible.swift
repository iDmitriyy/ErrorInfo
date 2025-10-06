//
//  OrderedMultipleValuesForKeyStorage+.swift
//  ErrorInfo
//
//  Created by tmp on 06/10/2025.
//

extension OrderedMultipleValuesForKeyStorage: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    switch _variant {
    case .left(let singleValueForKeyDict): String(describing: singleValueForKeyDict)
    case .right(let multiValueForKeyDict): String(describing: multiValueForKeyDict)
    }
  }
  
  public var debugDescription: String {
    switch _variant {
    case .left(let singleValueForKeyDict): String(reflecting: singleValueForKeyDict)
    case .right(let multiValueForKeyDict): String(reflecting: multiValueForKeyDict)
    }
  }
}
