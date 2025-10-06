//
//  OrderedMultiValueErrorInfoGeneric+.swift
//  ErrorInfo
//
//  Created by tmp on 06/10/2025.
//

extension OrderedMultiValueErrorInfoGeneric: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { String(describing: _storage) }
  
  public var debugDescription: String { String(reflecting: _storage) }
}
