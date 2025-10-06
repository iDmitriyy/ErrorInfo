//
//  OrderedMultiValueDictionary+ValuesForKeySlice.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 05/10/2025.
//

// MARK: - AllValues ForKey View

extension OrderedMultiValueDictionary {
  internal typealias EntryElement = Element
  
  internal struct ValuesForKeySlice: Sequence { //  ~Escapable
    // TODO: ~Escapable | as DiscontiguousSlice is used, View must not outlive source
//    public typealias Element = Value
    
    private let entriesSlice: DiscontiguousSlice<[EntryElement]>
    
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
