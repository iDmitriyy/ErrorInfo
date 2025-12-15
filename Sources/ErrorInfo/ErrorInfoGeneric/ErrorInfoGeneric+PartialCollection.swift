//
//  ErrorInfoGeneric+PartialCollection.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

extension ErrorInfoGeneric: Collection {
  public var count: Int { _storage.count }
  
  public var isEmpty: Bool { _storage.isEmpty }
}

extension ErrorInfoGeneric: RandomAccessCollection {
  public var startIndex: Int { _storage.startIndex }
  
  public var endIndex: Int { _storage.endIndex }
  
  public subscript(position: Int) -> Element { _storage[position] }
}
