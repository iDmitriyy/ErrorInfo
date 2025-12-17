//
//  ErrorInfo+Sequence.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 28/11/2025.
//

extension ErrorInfo: Sequence {
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var base: BackingStorage.Iterator
    
    @inlinable
    internal init(base: BackingStorage.Iterator) {
      self.base = base
    }
    
    @inlinable
    public mutating func next() -> Element? {
      // It works like `.compacted()`, skipping all nil values
      while let (key, taggedRecord) = base.next() {
        guard let value = taggedRecord.record.someValue.getWrapped else { continue }
        return (key, value)
      }
      return nil
    }
  }

  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(base: _storage.makeIterator())
  }
}
