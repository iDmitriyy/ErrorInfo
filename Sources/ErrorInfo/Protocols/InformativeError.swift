//
//  InformativeError.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

public protocol InformativeError: Error {
  associatedtype ErrorInfoType
  
  var errorInfo: ErrorInfoType { get }
}
