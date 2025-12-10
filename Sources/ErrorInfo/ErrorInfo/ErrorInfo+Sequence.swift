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
      while let (key, taggedRecord) = base.next() {
        let record = taggedRecord.value
        guard let value = record._optional.optionalValue else { continue }
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
