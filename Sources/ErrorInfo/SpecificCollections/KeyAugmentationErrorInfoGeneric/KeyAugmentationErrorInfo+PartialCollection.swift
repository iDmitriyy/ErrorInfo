//
//  KeyAugmentationErrorInfo+PartialCollection.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 15/10/2025.
//

extension KeyAugmentationErrorInfoGeneric {
  public func makeIterator() -> some IteratorProtocol<Element> {
    _storage.makeIterator()
  }
}
