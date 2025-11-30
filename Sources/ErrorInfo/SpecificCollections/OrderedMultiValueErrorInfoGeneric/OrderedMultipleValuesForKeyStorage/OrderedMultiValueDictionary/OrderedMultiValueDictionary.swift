//
//  OrderedMultiValueDictionary.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 20/09/2025.
//

import SwiftCollectionsNonEmpty
import OrderedCollections
private import StdLibExtensions
private import Algorithms

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
          if ErrorInfoFuncs.isEqualAny(currentValue, nextValue) {
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
  
  public var hasMultipleValuesForAtLeastOneKey: Bool {
    for indices in _keyToEntryIndices.values where indices.count > 1 {
      return true
    }
    return false
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
    switch indexSet._variant {
    case .single(let index): // Typically there is only one value for key
      valuesForKey = ValuesForKey(element: _entries[index].value)
       
    case .multiple(let indices):
      let valuesForKeyArray = indices.map { index in _entries[index].value }
      valuesForKey = ValuesForKey(array: valuesForKeyArray)
    }
    return valuesForKey
  }
  
  @discardableResult
  public mutating func removeAllValues(forKey key: Key) -> ValuesForKey<Value>? {
    guard let indexSetForKey = _keyToEntryIndices.removeValue(forKey: key) else { return nil }
      
    let removedValues: ValuesForKey<Value>
    switch indexSetForKey._variant {
    case .single(let index): // Typically there is only one value for key
      let removedElement = _entries.remove(at: index)
      removedValues = ValuesForKey(element: removedElement.value)
       
    case .multiple(let indicesToRemove):
      let removedValuesArray = indicesToRemove.map { index in _entries[index].value }
      _entries.removeSubranges(indicesToRemove.asRangeSet(for: _entries))
      removedValues = ValuesForKey(array: removedValuesArray)
    }
    _rebuildKeyToEntryIndices()
    return removedValues
  }
  
  private mutating func _rebuildKeyToEntryIndices() {
    _keyToEntryIndices = [:]
    for (index, entry) in _entries.indexed() {
      _insert(entryIndex: index, forKey: entry.key)
    }
  }
  
  public mutating func removeAll(where predicate: (_ key: Key, _ value: Value) -> Bool) {
    self = self.filter { key, value in !predicate(key, value) }
  }
    
  public func filter(_ isIncluded: (Element) -> Bool) -> Self {
    var result: Self = [:]
    for element in self where isIncluded(element) {
      result.append(element)
    }
    return result
  }
}

// MARK: Append KeyValue

extension OrderedMultiValueDictionary {
  public mutating func append(key: Key, value: Value) {
    let newEntryIndex = _entries.endIndex
    _insert(entryIndex: newEntryIndex, forKey: key)
    _entries.append((key, value))
  }
  
  private mutating func _insert(entryIndex: Int, forKey key: Key) {
    if let bucketIndex = _keyToEntryIndices.index(forKey: key) {
      _keyToEntryIndices.values[bucketIndex].insert(entryIndex)
    } else {
      _keyToEntryIndices[key] = .single(index: entryIndex)
    }
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
