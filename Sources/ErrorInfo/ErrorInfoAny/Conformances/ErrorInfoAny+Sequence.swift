//
//  ErrorInfoAny+Sequence.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 21/12/2025.
//

extension ErrorInfoAny: Sequence {
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var base: BackingStorage.Iterator
    
    @inlinable
    internal init(base: BackingStorage.Iterator) {
      self.base = base
    }
    
    @inlinable
    @inline(__always)
    public mutating func next() -> Element? {
      // It works like `.compacted()`, skipping all nil values
      while let (key, annotated) = base.next() {
        let record = annotated.record
        if let value = record.someValue.getWrapped {
          return (key, value)
        }
      }
      return nil
    }
  }

  @inlinable
  @inline(__always)
  public func makeIterator() -> Iterator {
    Iterator(base: _storage.makeIterator())
  }
}
