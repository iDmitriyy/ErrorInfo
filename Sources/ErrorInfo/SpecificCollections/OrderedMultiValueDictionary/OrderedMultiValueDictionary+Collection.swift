//
//  OrderedMultiValueDictionary+Collection.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

extension OrderedMultiValueDictionary: Collection {
  public var count: Int { _entries.count }
  
  public var isEmpty: Bool { _entries.isEmpty }
}

extension OrderedMultiValueDictionary: RandomAccessCollection { // ! RandomAccessCollection
  public var startIndex: Int { _entries.startIndex }
  
  public var endIndex: Int { _entries.endIndex }
    
  public subscript(position: Int) -> Element { _entries[position] }
}

/*
 TODO:
 1) conform it to DictionaryProtocol for using with Dict merge / addPrefix functions
 2) AllValuesForKeyView ~Escapable | RangeSet instaed IndexSet | entries without storing keys
 */
