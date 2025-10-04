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
import func InternalCollectionsUtilities._dictionaryDescription

// MARK: - Ordered MultiValueDictionary

public struct OrderedMultiValueDictionary<Key: Hashable, Value>: Sequence {
  public typealias Element = (key: Key, value: Value)
  
  private var _entries: [EntryElement]
  /// for `allValuesForKey` function
  /// stores indices for all values for a key
  private var _keyEntryIndices: OrderedDictionary<Key, NonEmptyOrderedIndexSet> // TODO: ? use RangeSet instead of NonEmptyOrderedIndexSet?
  
//  private var __entries: [Value] // _entries wthout Key duplicated copies
  // [`indexOf value in __entries`: `index of its key in _keyEntryIndices.keys`]
//  private var __keyIndices: [Int: Int]
  
  public var keys: some RandomAccessCollection<Key> & _UniqueCollection { _keyEntryIndices.keys }
  
  public var count: Int { _entries.count }
  
  public var isEmpty: Bool { _entries.isEmpty }
  
  public init() {
    _entries = []
    _keyEntryIndices = [:]
  }
  
  public init(minimumCapacity: Int) {
    _entries = Array(minimumCapacity: minimumCapacity)
    _keyEntryIndices = OrderedDictionary(minimumCapacity: minimumCapacity)
  }
  
  public func makeIterator() -> some IteratorProtocol<(key: Key, value: Value)> {
    _entries.makeIterator()
  }
  
  func keyValuesView(shouldOmitEqualValue omitEqualValues: Bool) {
    let allEntriesIndices = RangeSet(_entries.indices)
    let allEntriesSlice = _entries[...]
    
    
    if omitEqualValues {
      for (key, entryIndices) in _keyEntryIndices where entryIndices.count > 1 {
        let valuesIndices = entryIndices.asRangeSet(for: _entries)
        let invertedIndices = allEntriesIndices.subtracting(valuesIndices)
        
        var valuesForKeySlice = allEntriesSlice
        valuesForKeySlice.removeSubranges(invertedIndices) // FIXME: might be inefficient
        var currentElement = valuesForKeySlice.first!
        var nextElementsSlice = valuesForKeySlice.dropFirst()
        while !nextElementsSlice.isEmpty {
          let duplicatedElementsIndices = nextElementsSlice.indices(where: { nextElement in
            ErrorInfoFuncs.isApproximatelyEqualAny(currentElement, nextElement)
          })
          valuesForKeySlice.removeSubranges(duplicatedElementsIndices)
          nextElementsSlice.removeSubranges(duplicatedElementsIndices)
          if let nextElement = nextElementsSlice.first {
            currentElement = nextElement
            nextElementsSlice = nextElementsSlice.dropFirst()
          }
        }
      }
    } else {
      // let allEntries = _entries[allEntriesIndices]
      let values = allEntriesSlice.map { $0.value }
      print(values)
    } // end if omitEqualValues
  }
  
  func getUnique() {
    typealias Index = Int
    typealias Entries = [EntryElement] // EntryElement
    
    var allEntriesRangeSet: RangeSet<Index> = RangeSet(_entries.indices)
    
    for (key, allValuesForKeyOrderedIndexSet) in _keyEntryIndices where allValuesForKeyOrderedIndexSet.count > 1 {
      let allValuesForKeyRangeSet: RangeSet<Index> = allValuesForKeyOrderedIndexSet.asRangeSet(for: _entries)
      let allValuesForKeyDiscSlice: DiscontiguousSlice<Entries> = _entries[allValuesForKeyRangeSet]
      
      var uniqueValuesForKeyIndices: RangeSet<Index> = allValuesForKeyRangeSet
      var currentElement = allValuesForKeyDiscSlice.first!
      var nextElementsSlice: DiscontiguousSlice<Entries> = allValuesForKeyDiscSlice.dropFirst()
      
      var resultIndices: RangeSet<Index> = allValuesForKeyRangeSet
      var nextElementsIndices: RangeSet<Index> = allValuesForKeyRangeSet
      while true {
        let duplicatedElementsRangeSet = nextElementsSlice.indices(where: { nextElement in
          ErrorInfoFuncs.isApproximatelyEqualAny(currentElement, nextElement)
        })
        
        for range in duplicatedElementsRangeSet.ranges {
          let adaptedRange: Range<Index> = range.lowerBound.base..<range.upperBound.base
          allEntriesRangeSet.remove(contentsOf: adaptedRange)
        }
        
      }
      
      switch allValuesForKeyOrderedIndexSet.count {
      case 2:
        let index0 = allValuesForKeyOrderedIndexSet[0]
        let index1 = allValuesForKeyOrderedIndexSet[1]
        if ErrorInfoFuncs.isApproximatelyEqualAny(_entries[index0].value, _entries[index1].value) {
          allEntriesRangeSet.remove(index1, within: _entries)
        }
      default:
        
        break
      }
      // DiscontiguousSlice<Array<(key: Key, value: Value)>>.SubSequence
    } // end for
  }
  
  func dfsdf() {
    // DiscontiguousSlice<[(key: Key, value: Value)]>.Index
    // let allValuesForKeyIndices = _keyEntryIndices[_keyEntryIndices.startIndex].value.asRangeSet(for: _entries)
    // var discSlice: DiscontiguousSlice<Array<(key: Key, value: Value)>> = _entries[allValuesForKeyIndices]
    // let discSliceSubseq: DiscontiguousSlice<Array<(key: Key, value: Value)>> = discSlice[...]
  }
}

extension OrderedMultiValueDictionary: Collection { // ! RandomAccessCollection
  public typealias Index = Int
  
  public var startIndex: Int { _entries.startIndex }
  
  public var endIndex: Int { _entries.endIndex }
  
  public func index(after i: Int) -> Int { _entries.index(after: i) }
  
  public subscript(position: Int) -> (key: Key, value: Value) {
    _entries[position]
  }
}

extension OrderedMultiValueDictionary: CustomDebugStringConvertible {
  public var debugDescription: String { InternalCollectionsUtilities._dictionaryDescription(for: self) }
}

extension OrderedMultiValueDictionary: Sendable where Key: Sendable, Value: Sendable {}

extension OrderedMultiValueDictionary: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init()
    
    for (key, value) in elements {
      self.append(key: key, value: value)
    }
  }
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
    _keyEntryIndices.hasValue(forKey: key)
  }
  
//  func ddd() -> some ~Escapable {
//
//  }
  
  public func allValuesView(forKey key: Key) -> AllValuesForKey? { // & ~Escapable
    if let allValuesForKeyIndices = _keyEntryIndices[key] {
      AllValuesForKey(entries: _entries, valueIndices: allValuesForKeyIndices)
    } else {
      nil as Optional<AllValuesForKey>
    }
  }
  
//  public func allValuesView(forKey key: Key) -> (some Sequence<Value>)? { // & ~Escapable
//    if let allValuesForKeyIndices = _keyEntryIndices[key] {
//      AllValuesForKeyView(entries: _entries, valueIndices: allValuesForKeyIndices)
//    } else {
//      nil as Optional<AllValuesForKeyView>
//    }
//  }
  
  @available(*, deprecated, message: "allValuesView(forKey:)")
  public func allValues(forKey key: Key) -> NonEmpty<some Collection<Value>>? {
    guard let indices = _keyEntryIndices[key] else { return Optional<NonEmptyArray<Value>>.none }
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
    if var indices = _keyEntryIndices[key] {
      indices.insert(index)
      _keyEntryIndices[key] = indices
    } else {
      _keyEntryIndices[key] = .single(index: index)
    }
    
    _entries.append((key, value))
  }
  
  public mutating func append(_ newElement: (key: Key, value: Value)) {
    append(key: newElement.key, value: newElement.value)
  }
  
  public mutating func removeAllValues(forKey key: Key) {
    guard let indices = _keyEntryIndices[key] else { return }
    
    switch indices {
    case .single(let index):
      // Typycally there is only one value for key
      _entries.remove(at: index)
    case .multiple:
      let indicesToRemove = indices.asRangeSet(for: _entries)
      _entries.removeSubranges(indicesToRemove)
    }
    _keyEntryIndices.removeValue(forKey: key)
  }
  
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _entries.removeAll(keepingCapacity: keepCapacity)
    _keyEntryIndices.removeAll(keepingCapacity: keepCapacity)
  }
}

// MARK: - AllValues ForKey View

extension OrderedMultiValueDictionary {
  fileprivate typealias EntryElement = Element
  
  /// Adapter for changing element type from (key: Key, value: Value) to Value
  public struct AllValuesForKey: Sequence { //  ~Escapable
    // TODO: ~Escapable | as DiscontiguousSlice is used, View must not outlive source
    public typealias Element = Value
    private let entries: [EntryElement]
    private let valueIndices: NonEmptyOrderedIndexSet
    
//    @lifetime(borrow entries)
//    @_lifetime(immortal)
    fileprivate init(entries: [EntryElement], valueIndices: NonEmptyOrderedIndexSet) {
      self.entries = entries
      self.valueIndices = valueIndices
    }
    
    public func makeIterator() -> some IteratorProtocol<Value> {
      let slicedEntries: DiscontiguousSlice<[EntryElement]> = entries[valueIndices.asRangeSet(for: entries)]
      var iterator = slicedEntries.makeIterator()
      return AnyIterator<Value> { iterator.next()?.value }
    }
  }
}

// MARK: - NonEmpty Ordered IndexSet

/// Introduced for implementing OrderedMultiValueDictionary. In most cases, Error-info types contain 1 value for a given key.
/// When there are multiple values for key, multiple indices are also stored. This `NonEmpty Ordered IndexSet` store single index as a value type, and heap allocated
/// OrderedSet is only created when there are 2 or more indices.
internal enum NonEmptyOrderedIndexSet: RandomAccessCollection {
  case single(index: Int)
  case multiple(indices: NonEmpty<OrderedSet<Int>>)
  
  typealias Element = Int
  
  internal var startIndex: Int { 0 }
  
  internal var endIndex: Int {
    switch self {
    case .single: 1
    case .multiple(let indices): indices.endIndex
    }
  }
  
  internal subscript(position: Int) -> Element {
    switch self {
    case .single(let index):
      switch position {
      case 0: return index
      default: preconditionFailure("Index \(position) is out of bounds")
      }
    case .multiple(let indices):
      return indices.base[position]
    }
  }
  
  @available(*, deprecated, message: "not optimal")
  internal var _asHeapNonEmptyOrderedSet: NonEmpty<OrderedSet<Int>> { // TODO: confrom Sequence protocol instead of this
    switch self {
    case let .single(index): NonEmpty(rawValue: OrderedSet<Int>(arrayLiteral: index))!
    case let .multiple(indices): indices
    }
  }
  
  internal func asRangeSet<C>(for collection: C) -> RangeSet<Int> where C: Collection, C.Index == Int {
    switch self {
    case let .single(index): RangeSet(CollectionOfOne(index), within: collection)
    case let .multiple(indices): RangeSet(indices, within: collection)
    }
  }
  
  internal mutating func insert(_ newIndex: Int) {
    switch consume self {
    case .single(let currentIndex):
      self = .multiple(indices: NonEmpty<OrderedSet<Int>>(rawValue: [currentIndex, newIndex])!)
    case .multiple(let elements):
      var rawValue = elements.rawValue // TODO: remove cow
      rawValue.append(newIndex)
      self = .multiple(indices: NonEmpty<OrderedSet<Int>>(rawValue: rawValue)!)
    }
  }
  
//  internal func contains(where predicate: (Int) throws -> Bool) rethrows -> Bool {
//    switch self {
//    case .single(let index): try predicate(index)
//    case .multiple(let indices): try indices.contains(where: predicate)
//    }
//  }
}
