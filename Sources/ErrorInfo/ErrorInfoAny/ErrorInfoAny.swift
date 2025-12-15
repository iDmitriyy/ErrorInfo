//
//  ErrorInfoAny.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

enum ErrorInfoOptionalAny: ErrorInfoOptionalProtocol {
  case value(Any)
  case nilInstance(typeOfWrapped: any Any.Type)
  
  var isValue: Bool {
    switch self {
    case .value: true
    case .nilInstance: false
    }
  }
  
  var getWrapped: Any? {
    switch self {
    case .value(let value): value
    case .nilInstance: nil
    }
  }
}
