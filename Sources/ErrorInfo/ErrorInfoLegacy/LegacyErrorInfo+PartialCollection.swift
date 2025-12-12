//
//  LegacyErrorInfo+PartialCollection.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 15/10/2025.
//

extension LegacyErrorInfo {
  public var count: Int { _storage.count }
  
  public var isEmpty: Bool { _storage.isEmpty }
}

extension LegacyErrorInfo {
  public func makeIterator() -> some IteratorProtocol<Element> {
    _storage.makeIterator()
  }
}
