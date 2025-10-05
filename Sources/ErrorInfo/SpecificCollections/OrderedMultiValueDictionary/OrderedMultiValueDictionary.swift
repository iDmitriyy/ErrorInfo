//
//  OrderedMultiValueDictionary.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 20/09/2025.
//

public import struct NonEmpty.NonEmpty
private import typealias NonEmpty.NonEmptyArray

// import InternalCollectionsUtilities
import OrderedCollections
private import StdLibExtensions
public import protocol InternalCollectionsUtilities._UniqueCollection

// MARK: - Ordered MultiValueDictionary

public struct OrderedMultiValueDictionary<Key: Hashable, Value>: Sequence {
  public typealias Element = (key: Key, value: Value)
  
  private var _entries: [Element]
  /// for `allValuesForKey` function
  /// stores indices for all values for a key
  private var _keyToEntryIndices: OrderedDictionary<Key, NonEmptyOrderedIndexSet> // TODO: ? use RangeSet instead of NonEmptyOrderedIndexSet?
    
  public var keys: some RandomAccessCollection<Key> & _UniqueCollection { _keyToEntryIndices.keys }
  
  public init() {
    _entries = []
    _keyToEntryIndices = [:]
  }
  
  public init(minimumCapacity: Int) {
    _entries = Array(minimumCapacity: minimumCapacity)
    _keyToEntryIndices = OrderedDictionary(minimumCapacity: minimumCapacity)
  }
    
  func approximatelyUniqueValuesWithKeys() -> some Collection<Element> {
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

// MARK: Get methods

extension OrderedMultiValueDictionary {
  public subscript(key: Key) -> Value {
    @available(*, unavailable, message: "This is a set only subscript")
    get { fatalError("unavailable") } // allValues(forKey: key)?.first
    set { append(key: key, value: newValue) }
  }
  
  @available(*, deprecated, message: "allValuesView(forKey:)")
  public subscript(key: Key) -> NonEmpty<some Collection<Value>>? {
    allValues(forKey: key)
  }

  public func hasValue(forKey key: Key) -> Bool {
    _keyToEntryIndices.hasValue(forKey: key)
  }
  
  public func allValuesView(forKey key: Key) -> (some Sequence<Value>)? { // & ~Escapable
    if let allValuesForKeyIndices = _keyToEntryIndices[key] {
      AllValuesForKey(entries: _entries, valueIndices: allValuesForKeyIndices)
    } else {
      nil as Optional<AllValuesForKey>
    }
  }
    
  @available(*, deprecated, message: "allValuesView(forKey:)")
  public func allValues(forKey key: Key) -> NonEmpty<some Collection<Value>>? {
    guard let indices = _keyToEntryIndices[key] else { return Optional<NonEmptyArray<Value>>.none }
    // TODO: need smth more optimal instead of allocating new Array, e.g.:
    // 1) MultiValueContainer enum | case single(element: ), case multiple(elements: )
    // 2) for multiple elements NonEmptyArray<Value>
    return indices._asHeapNonEmptyOrderedSet.map { _entries[$0].value }
  }
}

// MARK: Mutating methods

extension OrderedMultiValueDictionary {
  public mutating func append(key: Key, value: Value) {
    let index = _entries.endIndex
    if var indices = _keyToEntryIndices[key] {
      indices.insert(index)
      _keyToEntryIndices[key] = indices
    } else {
      _keyToEntryIndices[key] = .single(index: index)
    }
    _entries.append((key, value))
  }
  
  // public mutating func append(_ newElement: (Key, Value)) {
  //   append(key: newElement.0, value: newElement.1)
  // }
  
  public mutating func removeAllValues(forKey key: Key) {
    guard let indices = _keyToEntryIndices[key] else { return }
    
    switch indices._storage {
    case .single(let index):
      _entries.remove(at: index) // Typically there is only one value for key
    case .multiple:
      let indicesToRemove = indices.asRangeSet(for: _entries)
      _entries.removeSubranges(indicesToRemove)
    }
    _keyToEntryIndices.removeValue(forKey: key)
  }
  
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _entries.removeAll(keepingCapacity: keepCapacity)
    _keyToEntryIndices.removeAll(keepingCapacity: keepCapacity)
  }
}

