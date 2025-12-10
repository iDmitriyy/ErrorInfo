//
//  VariadicTuple.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

struct VariadicTuple<each T> {
  let elements: (repeat each T)
  
  init(_ elements: repeat each T) {
    self.elements = (repeat each elements)
  }
}

extension Collection {
  @inlinable @inline(__always)
  internal func apply<T>(_ function: (Self) -> T) -> T {
    function(self)
  }
}
