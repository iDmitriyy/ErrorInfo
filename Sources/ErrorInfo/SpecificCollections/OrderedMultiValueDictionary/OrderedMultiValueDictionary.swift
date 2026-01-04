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
internal
struct OrderedMultiValueDictionary<Key: Hashable, Value>: Sequence {
  @usableFromInline typealias Element = (key: Key, value: Value)
  
  @usableFromInline internal var _entries: ContiguousArray<Element>
  
  @usableFromInline internal var _keyToEntryIndices: Dictionary<Key, NonEmptyOrderedIndexSet>
  // TODO: ? use RangeSet instead of NonEmptyOrderedIndexSet?
  
  @usableFromInline internal init() {
    _entries = []
    _keyToEntryIndices = [:]
  }
  
  @usableFromInline
  internal init(minimumCapacity: Int) {
    _entries = ContiguousArray(minimumCapacity: minimumCapacity)
    _keyToEntryIndices = Dictionary(minimumCapacity: minimumCapacity)
  }
  
  @inlinable
  @inline(__always)
  internal static func migratedFrom(singleValueForKeyDictionary source: OrderedDictionary<Key, Value>)
  -> OrderedMultiValueDictionary<Key, CollisionAnnotatedRecord<Value>> {
    let capacity = source.count + 1
    var output = OrderedMultiValueDictionary<Key, CollisionAnnotatedRecord<Value>>(minimumCapacity: capacity)
    
    for index in source.indices {
      let (key, value) = source[index]
      output._keyToEntryIndices[key] = .single(index: index)
      output._entries.append((key, CollisionAnnotatedRecord.value(value)))
    }
    return output
  }
  
  @inlinable @inline(__always)
  internal mutating func reserveCapacity(_ minimumCapacity: Int) {
    _entries.reserveCapacity(minimumCapacity)
    _keyToEntryIndices.reserveCapacity(minimumCapacity)
  }
}

extension OrderedMultiValueDictionary: Sendable where Key: Sendable, Value: Sendable {}

extension OrderedMultiValueDictionary {
  @usableFromInline
  func hasValue(forKey key: Key) -> Bool {
    _keyToEntryIndices.hasValue(forKey: key)
  }
  
  internal func hasMultipleValues(forKey key: Key) -> Bool {
    guard let entriesForKeyIndices = _keyToEntryIndices[key] else { return false }
    return entriesForKeyIndices.count > 1
  }
  
  internal var hasMultipleValuesForAtLeastOneKey: Bool {
    for entriesIndices in _keyToEntryIndices.values where entriesIndices.count > 1 {
      return true
    }
    return false
  }
}

// MARK: All Values For Key

extension OrderedMultiValueDictionary {
  @usableFromInline
  internal func allValues(forKey key: Key) -> ItemsForKey<Value>? {
    guard let indexSet = _keyToEntryIndices[key] else { return nil }
    
    let valuesForKey: ItemsForKey<Value>
    switch indexSet._variant {
    case .left(let index): // Typically there is only one value for key
      valuesForKey = ItemsForKey(element: _entries[index].value)
       
    case .right(let indices):
      let valuesForKeyArray = indices.map { index in _entries[index].value }
      valuesForKey = ItemsForKey(array: valuesForKeyArray)
    }
    return valuesForKey
  }
  
  @discardableResult
  internal mutating func removeAllValues(forKey key: Key) -> ItemsForKey<Value>? {
    guard let indexSetForKey = _keyToEntryIndices.removeValue(forKey: key) else { return nil }
      
    let removedValues: ItemsForKey<Value>
    switch indexSetForKey._variant {
    case .left(let index): // Typically there is only one value for key
      let removedElement = _entries.remove(at: index)
      removedValues = ItemsForKey(element: removedElement.value)
       
    case .right(let indicesToRemove):
      let removedValuesArray = indicesToRemove.map { index in _entries[index].value }
      _entries.removeSubranges(indicesToRemove.asRangeSet(for: _entries))
      removedValues = ItemsForKey(array: removedValuesArray)
    }
    _rebuildKeyToEntryIndices()
    return removedValues
  }
  
  private mutating func _rebuildKeyToEntryIndices() {
    _keyToEntryIndices.removeAll(keepingCapacity: true)
    for index in _entries.indices {
      _insert(entryIndex: index, forKey: _entries[index].key)
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
  @usableFromInline
  mutating func append(key: Key, value: Value) { // TODO: measure : inlining showed significant gain in related tests
    let newEntryIndex = _entries.endIndex
    _entries.append((key, value))
    _insert(entryIndex: newEntryIndex, forKey: key)
  }
  
  @inlinable
  @inline(__always)
  public mutating func _insert(entryIndex: Int, forKey key: Key) {
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
      for entryIndex in entryIndices {
        precondition(seenIndices.insert(entryIndex).inserted)
        
        let entry = _entries[entryIndex]
        precondition(entry.key == key)
        computedEntriesCount += 1
      }
    }
    
    precondition(_entries.count == computedEntriesCount)
  }
}
