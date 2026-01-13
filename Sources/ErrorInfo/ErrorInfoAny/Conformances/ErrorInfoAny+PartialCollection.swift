//
//  ErrorInfoAny+PartialCollection.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

extension ErrorInfoAny {
  @inlinable
  @inline(__always)
  public var count: Int { _storage.count }
  
  public var valuesCount: Int { _storage.valuesCount }
  
  @inlinable
  @inline(__always)
  public var isEmpty: Bool { _storage.isEmpty }
}
