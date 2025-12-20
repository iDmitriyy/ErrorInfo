//
//  OrderedMultiValueDictionary.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 20/09/2025.
//

import OrderedCollections
import SwiftCollectionsNonEmpty

/// An insertion‑ordered multi‑value dictionary used by `ErrorInfo` types to record one or more values per key.
///
/// Preserves the global insertion order of entries and the per‑key order of values. Per‑key
/// positions are tracked with `NonEmptyOrderedIndexSet` to avoid heap allocation in the
/// single‑value case and switch to a heap‑backed set only when needed.
///
/// `OrderedMultipleValuesForKeyStorage` is built on top this structure to support multiple values per key, collision handling,
/// and stable summaries while keeping append and lookup efficient.
///
/// Example
/// ```swift
/// var dict = OrderedMultiValueDictionary<String, Int>()
/// dict.append(key: "id", value: 1)
/// dict.append(key: "id", value: 2)   // same key, second value
/// dict.append(key: "name", value: 3)
///
/// dict.hasValue(forKey: "id") // true
///
/// if let values = dict.allValues(forKey: "id") {
///   Array(values)                    // [1, 2] — order preserved
/// }
///
/// dict.removeAllValues(forKey: "id") // removes both values for "id"
/// ```
@usableFromInline
internal struct OrderedMultiValueDictionary<Key: Hashable, Value>: Sequence {
  public typealias Element = (key: Key, value: Value)
  
  @usableFromInline internal var _entries: [Element]
  
  @usableFromInline internal var _keyToEntryIndices: Dictionary<Key, NonEmptyOrderedIndexSet>
  // TODO: ? use RangeSet instead of NonEmptyOrderedIndexSet?
  
  @usableFromInline internal init() {
    _entries = []
    _keyToEntryIndices = [:]
  }
  
  internal init(minimumCapacity: Int) {
    _entries = Array(minimumCapacity: minimumCapacity)
    _keyToEntryIndices = Dictionary(minimumCapacity: minimumCapacity)
  }
}

extension OrderedMultiValueDictionary: Sendable where Key: Sendable, Value: Sendable {}

extension OrderedMultiValueDictionary {
  public func hasValue(forKey key: Key) -> Bool {
    _keyToEntryIndices.hasValue(forKey: key)
  }
  
  internal func hasMultipleValues(forKey key: Key) -> Bool {
    guard let entriesForKeyIndices = _keyToEntryIndices[key] else { return false }
    return entriesForKeyIndices.count > 1
  }
  
  internal var hasMultipleValuesForAtLeastOneKey: Bool {
    for entriesForKeyIndices in _keyToEntryIndices.values where entriesForKeyIndices.count > 1 {
      return true
    }
    return false
  }
}

// MARK: All Values For Key

extension OrderedMultiValueDictionary {
//  internal func allValuesSlice(forKey key: Key) -> (some Sequence<Value>)? { // & ~Escapable
//    if let allValuesForKeyIndices = _keyToEntryIndices[key] {
//      ValuesForKeySlice(entries: _entries, valueIndices: allValuesForKeyIndices)
//    } else {
//      nil as Optional<ValuesForKeySlice>
//    }
//  }
  
  internal func iterateAllValues(forKey key: Key, _ iteration: (Value) -> Void) {
    guard let indexSet = _keyToEntryIndices[key] else { return }
    
    switch indexSet._variant {
    case .left(let index): // Typically there is only one value for key
      iteration(_entries[index].value)
       
    case .right(let indices):
      for index in indices { iteration(_entries[index].value) }
    }
  }
  
  internal func allValues(forKey key: Key) -> ValuesForKey<Value>? {
    guard let indexSet = _keyToEntryIndices[key] else { return nil }
    
    let valuesForKey: ValuesForKey<Value>
    switch indexSet._variant {
    case .left(let index): // Typically there is only one value for key
      valuesForKey = ValuesForKey(element: _entries[index].value)
       
    case .right(let indices):
      let valuesForKeyArray = indices.map { index in _entries[index].value }
      valuesForKey = ValuesForKey(array: valuesForKeyArray)
    }
    return valuesForKey
  }
  
  @discardableResult
  internal mutating func removeAllValues(forKey key: Key) -> ValuesForKey<Value>? {
    guard let indexSetForKey = _keyToEntryIndices.removeValue(forKey: key) else { return nil }
      
    let removedValues: ValuesForKey<Value>
    switch indexSetForKey._variant {
    case .left(let index): // Typically there is only one value for key
      let removedElement = _entries.remove(at: index)
      removedValues = ValuesForKey(element: removedElement.value)
       
    case .right(let indicesToRemove):
      let removedValuesArray = indicesToRemove.map { index in _entries[index].value }
      _entries.removeSubranges(indicesToRemove.asRangeSet(for: _entries))
      removedValues = ValuesForKey(array: removedValuesArray)
    }
    _rebuildKeyToEntryIndices()
    return removedValues
  }
  
  private mutating func _rebuildKeyToEntryIndices() {
    _keyToEntryIndices = [:] // Improvement: Dictionary(minimumCapacity: _keyToEntryIndices.count - 1) | removeAll(keepingCapacity: true)
    for index in _entries.indices {
      let entry = _entries[index]
      _insert(entryIndex: index, forKey: entry.key)
    }
  }
  
  internal mutating func removeAll(where predicate: (_ key: Key, _ value: Value) -> Bool) {
    self = filter { key, value in !predicate(key, value) }
  }
    
  internal func filter(_ isIncluded: (Element) -> Bool) -> Self {
    var result: Self = Self()
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
  
  internal mutating func append(_ newElement: (Key, Value)) {
    append(key: newElement.0, value: newElement.1)
  }
}

extension OrderedMultiValueDictionary {
  internal mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _entries.removeAll(keepingCapacity: keepCapacity)
    _keyToEntryIndices.removeAll(keepingCapacity: keepCapacity)
  }
}

extension OrderedMultiValueDictionary {
  internal func _checkInvariants() {
    var computedEntriesCount: Int = 0
    var seenIndices = Set<Int>()
    
    for (key, entryIndices) in _keyToEntryIndices {
      precondition(!entryIndices.isEmpty) // entryIndices must be NonEmpty
      for enryIndex in entryIndices {
        precondition(seenIndices.insert(enryIndex).inserted)
        
        let entry = _entries[enryIndex]
        precondition(entry.key == key)
        computedEntriesCount += 1
      }
    }
    
    precondition(_entries.count == computedEntriesCount)
  }
}
