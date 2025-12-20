//
//  ErrorInfoGeneric+Collection.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

extension ErrorInfoGeneric: Collection {
  @inlinable
  @inline(__always)
  public var count: Int { _storage.count }
  
  @inlinable
  @inline(__always)
  public var isEmpty: Bool { _storage.isEmpty }
}

extension ErrorInfoGeneric: RandomAccessCollection {
  @inlinable
  public var startIndex: Int { _storage.startIndex }
  
  @inlinable
  public var endIndex: Int { _storage.endIndex }
  
  @inlinable
  @inline(__always)
  public subscript(position: Int) -> Element { _storage[position] }
}
