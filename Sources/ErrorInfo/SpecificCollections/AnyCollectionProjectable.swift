//
//  AnyCollectionProjectable.swift
//  ErrorInfo
//
//  Created by tmp on 06/12/2025.
//

internal struct AnyCollectionProjectable<Base: Collection, ElementProjection>: Collection {
  private let base: Base
  private let projection: (Base.Element) -> ElementProjection
    
  internal init(base: Base, elementProjection: @escaping (Base.Element) -> ElementProjection) {
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
  subscript(index: Base.Index) -> ElementProjection {
    projection(base[index])
  }
    
  @inline(__always)
  @inlinable
  func index(after i: Base.Index) -> Base.Index {
    base.index(after: i)
  }
}

internal struct AnySequenceProjectable<Base: Sequence, ElementProjection>: Sequence {
  private let base: Base
  private let projection: (Base.Element) -> ElementProjection
    
  internal init(base: Base, elementProjection: @escaping (Base.Element) -> ElementProjection) {
    self.base = base
    projection = elementProjection
  }
  
  @inline(__always)
  @inlinable
  func makeIterator() -> some IteratorProtocol<ElementProjection> {
    var iterator = base.makeIterator()
      
    return AnyIterator {
      while let next = iterator.next() {
        return projection(next)
      }
      return nil
    }
  }
}
