//
//  ErrorInfoPrototype.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

public protocol IterableErrorInfo<Key, Value>: Sequence where Key: Hashable, Self.Iterator.Element == (key: Key, value: Value) {
  associatedtype Key
  associatedtype Value
}

public protocol ErrorInfoPartialCollection<Key, Value>: ~Copyable { // : IterableErrorInfo
  associatedtype Key // temp while developong as ~Copyable
  associatedtype Value // < delete
  typealias Element = (key: Key, value: Value) // < delete
  
//  associatedtype Index
//  associatedtype Indices: Collection where Self.Indices == Self.Indices.SubSequence
  
  var isEmpty: Bool { get }
  
  var count: Int { get }
}
