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
      while let (key, valueWrapper) = base.next() {
        let maybeValue = valueWrapper.value
        guard let value = maybeValue.optionalValue else { continue }
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
