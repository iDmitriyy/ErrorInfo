//
//  ErrorInfo+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/10/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

extension ErrorInfo {
  public var keys: some Collection<String> & _UniqueCollection { _storage.keys }
  
  public var allKeys: some Collection<String> { _storage._storage.allKeys }
}

extension ErrorInfo {
  public typealias FullInfoElement = (key: KeyWithOrigin, value: CollisionTaggedValue<_Optional, CollisionSource>)
  
  public var fullInfoView: some Sequence<FullInfoElement> {
    AnySequenceProjectable(base: _storage, elementProjection: { key, entry in
      let keyWithOrigin = KeyWithOrigin(string: key, origin: entry.value.keyOrigin)
      let collisionTaggedValue = CollisionTaggedValue(value: entry.value.optional, collisionSource: entry.collisionSource)
      return (keyWithOrigin, collisionTaggedValue)
    })
  }
}
