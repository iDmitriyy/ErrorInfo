//
//  OrderedMultiValueDictionary+ValuesForKeySlice.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 05/10/2025.
//

// MARK: - AllValues ForKey View

extension OrderedMultiValueDictionary {
  internal typealias EntryElement = Element
  
  internal struct ValuesForKeySlice: Sequence { //  ~Escapable
    // TODO: ~Escapable | as DiscontiguousSlice is used, View must not outlive source
//    public typealias Element = Value
    
    private let entriesSlice: DiscontiguousSlice<[EntryElement]>
    
    // @lifetime(borrow pointer)
    // @lifetime(borrow entries)
    internal init(entries: [EntryElement], valueIndices: NonEmptyOrderedIndexSet) {
      entriesSlice = entries[valueIndices.asRangeSet(for: entries)]
    }
    
    public func makeIterator() -> some IteratorProtocol<Value> {
      var iterator = entriesSlice.makeIterator()
      return AnyIterator<Value> { iterator.next()?.value }
    }
  }
}

extension OrderedMultiValueDictionary {
  typealias ParentType = Self
  
  internal struct ValuesForKeySlice_: ~Escapable {
    // TODO: ~Escapable | as DiscontiguousSlice is used, View must not outlive source
//    public typealias Element = Value
    
    private let entriesSlice: DiscontiguousSlice<[EntryElement]>
    
//    @_lifetime(borrow entries, valueIndices)
//    // @lifetime(immortal)
//    internal init(entries: borrowing [EntryElement], valueIndices: borrowing NonEmptyOrderedIndexSet) {
//      entriesSlice = entries[valueIndices.asRangeSet(for: entries)]
//    }
    
    @_lifetime(borrow outer)
    internal init(outer: borrowing ParentType) {
      fatalError()
      //entriesSlice = entries[valueIndices.asRangeSet(for: entries)]
    }
    
    public func makeIterator() -> some IteratorProtocol<Value> {
      var iterator = entriesSlice.makeIterator()
      if #available(macOS 26.0, *) {
        let span = [4].span
      } else {
        // Fallback on earlier versions
      }
      return AnyIterator<Value> { iterator.next()?.value }
    }
  }
  
  @_lifetime(borrow self)
  internal func allValuesSlice_(forKey key: Key) -> ValuesForKeySlice_? {
    if let allValuesForKeyIndices = _keyToEntryIndices[key] {
//      let slice = ValuesForKeySlice_(entries: _entries, valueIndices: allValuesForKeyIndices)
      let slice = ValuesForKeySlice_(outer: self)
      return unsafe _overrideLifetime(slice, borrowing: self)
    } else {
      let slice = nil as Optional<ValuesForKeySlice_>
      return unsafe _overrideLifetime(slice, borrowing: self)
    }
  }
  
  @_lifetime(borrow self)
  internal func allValuesSlice_2(forKey key: Key) -> ValuesForKeySlice_ {
    let slice = ValuesForKeySlice_(outer: self)
    return unsafe _overrideLifetime(slice, borrowing: self)
  }
}

import Foundation

func testLifeTime() {
  var dict: OrderedMultiValueDictionary<Int, Int>! = .init()
  
  if let slice = dict.allValuesSlice_(forKey: 0) {
    // Task { slice } // Error: Lifetime-dependent variable 'slice' escapes its scope
  }
  
  let slice = dict.allValuesSlice_2(forKey: 0)
  
  // dict.append(key: 0, value: 0)
  
  dict = nil // ! No error
  
}
