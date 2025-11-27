//
//  OrderedMultiValueDictionary.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 20/09/2025.
//

import SwiftCollectionsNonEmpty
import OrderedCollections
private import StdLibExtensions

// MARK: - Ordered MultiValueDictionary

public struct OrderedMultiValueDictionary<Key: Hashable, Value>: Sequence {
  public typealias Element = (key: Key, value: Value)
  
  internal private(set) var _entries: [Element]
  /// for `allValuesForKey` function
  /// stores indices for all values for a key
  internal private(set) var _keyToEntryIndices: Dictionary<Key, NonEmptyOrderedIndexSet> // TODO: ? use RangeSet instead of NonEmptyOrderedIndexSet?
  
  public init() {
    _entries = []
    _keyToEntryIndices = [:]
  }
  
  public init(minimumCapacity: Int) {
    _entries = Array(minimumCapacity: minimumCapacity)
    _keyToEntryIndices = Dictionary(minimumCapacity: minimumCapacity)
  }
    
  func approximatelyUniqueValuesWithKeysSlice() -> some Collection<Element> {
    var entriesRangeSet: RangeSet<Index> = RangeSet(_entries.indices)
    
    for (_, allValuesForKeyIndexSet) in _keyToEntryIndices where allValuesForKeyIndexSet.count > 1 {
      var valueForKeyIndices = allValuesForKeyIndexSet._asHeapNonEmptyOrderedSet.base
      
      var dropFirstCount: Int = 1
      var currentValue = _entries[allValuesForKeyIndexSet.first].value
      var nextIndices = valueForKeyIndices.dropFirst(dropFirstCount)
      while !nextIndices.isEmpty {
        for entryIndex in nextIndices { // remove equal values
          let nextValue = _entries[entryIndex].value
          if ErrorInfoFuncs.isApproximatelyEqualAny(currentValue, nextValue) {
            valueForKeyIndices.remove(entryIndex)
            entriesRangeSet.remove(entryIndex, within: _entries)
          }
        }
        // values example: 0 1 1 1 1 2 3 2 3 2 1 4
        let indicesAfterRemovingDuplicates = valueForKeyIndices.dropFirst(dropFirstCount)
        if let nextIndex = indicesAfterRemovingDuplicates.first {
          currentValue = _entries[nextIndex].value
        }
        dropFirstCount += 1
        nextIndices = indicesAfterRemovingDuplicates.dropFirst()
      }
    } // end `for (key, allValuesForKeyIndexSet)`
    
    let uniqueValuesSlice = _entries[entriesRangeSet]
    
    return uniqueValuesSlice
  }
}

extension OrderedMultiValueDictionary: Sendable where Key: Sendable, Value: Sendable {}

extension OrderedMultiValueDictionary {  
  public func hasValue(forKey key: Key) -> Bool {
    _keyToEntryIndices.hasValue(forKey: key)
  }
}

// MARK: All Values For Key

extension OrderedMultiValueDictionary {
  public func allValuesSlice(forKey key: Key) -> (some Sequence<Value>)? { // & ~Escapable
    if let allValuesForKeyIndices = _keyToEntryIndices[key] {
      ValuesForKeySlice(entries: _entries, valueIndices: allValuesForKeyIndices)
    } else {
      nil as Optional<ValuesForKeySlice>
    }
  }
  
  public func allValues(forKey key: Key) -> ValuesForKey<Value>? {
    guard let indexSet = _keyToEntryIndices[key] else { return nil }
    
    let valuesForKey: ValuesForKey<Value>
    switch indexSet._storage {
    case .single(let index): // Typically there is only one value for key
      valuesForKey = ValuesForKey(element: _entries[index].value)
       
    case .multiple(let indices):
      var accumulator = Array<Value>(minimumCapacity: indices.count)
      for index in indices.base {
        accumulator.append(_entries[index].value)
      }
      valuesForKey = ValuesForKey(array: accumulator)
    }
    return valuesForKey
  }
  
  @discardableResult
  public mutating func removeAllValues(forKey key: Key) -> ValuesForKey<Value>? {
    guard let indexSet = _keyToEntryIndices.removeValue(forKey: key) else { return nil }
      
    let oldValues: ValuesForKey<Value>
    switch indexSet._storage {
    case .single(let index): // Typically there is only one value for key
      let removedElement = _entries.remove(at: index)
      oldValues = ValuesForKey(element: removedElement.value)
       
    case .multiple(let indices):
      var accumulator = Array<Value>(minimumCapacity: indices.count)
      for index in indices.base {
        accumulator.append(_entries[index].value)
      }
      // FIXME: recalculate indices in _keyToEntryIndices
      let indicesToRemove = indices.asRangeSet(for: _entries)
      _entries.removeSubranges(indicesToRemove)
      oldValues = ValuesForKey(array: accumulator)
    }
    return oldValues
  }
}

// MARK: Append KeyValue

extension OrderedMultiValueDictionary {
  public mutating func append(key: Key, value: Value) {
    let entryAppendingIndex = _entries.endIndex
    if var indices = _keyToEntryIndices[key] {
      indices.insert(entryAppendingIndex) // FIXME: remove CoW. _keyToEntryIndices[index].insert(index)
      _keyToEntryIndices[key] = indices
    } else {
      _keyToEntryIndices[key] = .single(index: entryAppendingIndex)
    }
    _entries.append((key, value))
  }
  
  public mutating func append(_ newElement: (Key, Value)) {
    append(key: newElement.0, value: newElement.1)
  }
}

extension OrderedMultiValueDictionary {
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _entries.removeAll(keepingCapacity: keepCapacity)
    _keyToEntryIndices.removeAll(keepingCapacity: keepCapacity)
  }
}
