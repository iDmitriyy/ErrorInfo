//
//  ErrorInfo+PartialCollection.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 07/10/2025.
//

extension ErrorInfo {
  @inlinable
  @inline(__always)
  public var count: Int { _storage.count }
  
  @inlinable
  @inline(__always)
  public var isEmpty: Bool { _storage.isEmpty }
}
