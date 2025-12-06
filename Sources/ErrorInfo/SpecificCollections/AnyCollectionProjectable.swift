//
//  AnyCollectionProjectable.swift
//  ErrorInfo
//
//  Created by tmp on 06/12/2025.
//

internal struct AnyCollectionProjectable<Base: Collection, Projection>: Collection {
  private let base: Base
  private let projection: (Base.Element) -> Projection
    
  internal init(base: Base, elementProjection: @escaping (Base.Element) -> Projection) {
    self.base = base
    projection = elementProjection
  }
  
  @inline(__always)
  @inlinable
  var startIndex: Base.Index { base.startIndex }
  
  @inline(__always)
  @inlinable
  var endIndex: Base.Index { base.endIndex }
    
  @inline(__always)
  @inlinable
  subscript(index: Base.Index) -> Projection {
    projection(base[index])
  }
    
  @inline(__always)
  @inlinable
  func index(after i: Base.Index) -> Base.Index {
    base.index(after: i)
  }
}
