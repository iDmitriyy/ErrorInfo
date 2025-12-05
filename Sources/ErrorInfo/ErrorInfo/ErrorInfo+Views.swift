//
//  ErrorInfo+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/10/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

extension ErrorInfo {
  public var keys: some Collection<String> & _UniqueCollection {
    _storage.keys
  }
}

extension ErrorInfo {
  public var fullInfoView: FullInfoView { FullInfoView(base: self) }
  
  public struct FullInfoView: Sequence {
    public typealias Element = (key: KeyWithOrigin, value: CollisionTaggedValue<_Optional, CollisionSource>)
    
    private let base: ErrorInfo
    
    internal init(base: ErrorInfo) {
      self.base = base
    }
    
    public func makeIterator() -> some IteratorProtocol<Element> {
      var iterator = base._storage.makeIterator()
      
      return AnyIterator {
        guard let (key, entry) = iterator.next() else { return nil }
        
        let keyWithOrigin = KeyWithOrigin(string: key, origin: entry.value.keyOrigin)
        let collisionTaggedValue = CollisionTaggedValue(value: entry.value.optional, collisionSource: entry.collisionSource)
        
        return (keyWithOrigin, collisionTaggedValue)
      }
    }
  }
}
