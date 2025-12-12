//
//  OrderedMultiValueDictionary+CustomStringConvertible.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 05/10/2025.
//

private import func InternalCollectionsUtilities._dictionaryDescription


extension OrderedMultiValueDictionary: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { InternalCollectionsUtilities._dictionaryDescription(for: self) }
  
  public var debugDescription: String { InternalCollectionsUtilities._dictionaryDescription(for: self) }
}
