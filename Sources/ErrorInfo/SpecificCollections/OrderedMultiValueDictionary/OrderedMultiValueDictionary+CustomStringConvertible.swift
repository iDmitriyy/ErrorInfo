//
//  OrderedMultiValueDictionary+CustomStringConvertible.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 05/10/2025.
//

private import func InternalCollectionsUtilities._dictionaryDescription


extension OrderedMultiValueDictionary: CustomDebugStringConvertible {
  public var debugDescription: String { InternalCollectionsUtilities._dictionaryDescription(for: self) }
}
