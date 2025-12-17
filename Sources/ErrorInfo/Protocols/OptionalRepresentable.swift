//
//  OptionalRepresentable.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

protocol ErrorInfoOptionalRepresentable {
  associatedtype Wrapped
  associatedtype TypeOfWrapped
  
  static func value(_: Wrapped) -> Self
  static func nilInstance(typeOfWrapped: TypeOfWrapped) -> Self
  
  var getWrapped: Wrapped? { get }
  
  var isValue: Bool { get } // TODO: - check perfomance with inlining
}

extension ErrorInfoOptionalRepresentable {
//  @inlinable @inline(__always) var isNil: Bool { !isValue }
}
