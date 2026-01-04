//
//  OrderedMultipleValuesForKeyStoragePerformanceTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

@testable import ErrorInfo
import OrderedCollections
import Testing

// !rewrite
struct OrderedMultipleValuesForKeyStoragePerformanceTests {
  private let elements = 1...50000
  
  @Test func addUniqueKeysWithSingleValue() {
    let count = 10
    let dictOutput = performMeasuredAction(count: count) {
      var dict: [Int: Int] = [:]
      for element in elements {
        dict[element] = element
      }
      return dict
    }
    
    let orderedDictOutput = performMeasuredAction(count: count) {
      var dict: OrderedDictionary<Int, Int> = [:]
      for element in elements {
        dict[element] = element
      }
      return dict
    }
    
    // on debug builds:
    // ~1.5 slower vs OrderedDictionary
    // ~9.5x slower vs Swift.Dictionary
    // TODO: compare on optimized build
    let orderedMultiValueStorageOutput = performMeasuredAction(count: count) {
      var dict = OrderedMultipleValuesForKeyStorage<Int, Int>(minimumCapacity: elements.count)
      for element in elements {
        dict.appendUnconditionally(key: element, value: element, writeProvenance: .onSubscript(origin: nil))
      }
      return dict
    }
    
    print(dictOutput.duration, orderedDictOutput.duration, orderedMultiValueStorageOutput.duration)
  }
    
  @Test func getSingleValueForKey() {
    // measure OrderedMultipleValuesForKeyStorage.ItemsForKey overhead
  }
  
  @Test func hasValueForKey() {
    var array = ["": ""]
    
    let isU1 = unsafeHasUniquelyReferencedStorage_(&array)
    
//    var array2 = array
    
    let isU2 = unsafeHasUniquelyReferencedStorage_(&array)
    
    print("HasUniquelyReferencedStorage", isU1, isU2)
  }
  
  @Test func count() {
    
  }
  
  @Test func isEmpty() {
    
  }
  
  @Test func initWithDictionaryLiteralUniqueKeysWithSingleValue() {
    // OrderedMultipleValuesForKeyStorage has special initializer
  }
  
  @Test func contentMemoryConsumption() {
    // check amount of memory needed for storing Keys & Values for Dictionary, OrderedDictionary, OrderedMultiValueDictionary
  }
  
  @Test func asStringDictDefaultInterpolationUniqueKeysWithSingleValue() {
    // asStringDict() vs String(describing:)
  }
  
  // test creation of empty collections vs their backing data structures
  // subscript performance test
}

extension ObjectIdentifier {
  /// Returns true iff the object identified by `self` is uniquely referenced.
  ///
  /// - Requires: the object identified by `self` exists.
  /// - Note: will only work when called from a mutating method
  @_transparent public func _liveObjectIsUniquelyReferenced() -> Bool {
    var me = self
    return withUnsafeMutablePointer(to: &me) {
      $0.withMemoryRebound(to: AnyObject.self, capacity: 1) {
        isKnownUniquelyReferenced(&$0.pointee)
      }
    }
  }
}

/// Returns `true` iff the reference contained in `x` is uniquely referenced.
///
/// - Requires: `T` contains exactly one reference or optional reference
///   and no other stored properties or is itself a reference.
@_transparent public func unsafeHasUniquelyReferencedStorage<T>(_ x: inout T) -> Bool {
  unsafeBitCast(x, to: ObjectIdentifier.self)._liveObjectIsUniquelyReferenced()
}


@_transparent public func unsafeHasUniquelyReferencedStorage_<T>(_ x: inout T) -> Bool {
  var id = unsafeBitCast(x, to: ObjectIdentifier.self)
  return withUnsafeMutablePointer(to: &id) {
    $0.withMemoryRebound(to: AnyObject.self, capacity: 1) {
      isKnownUniquelyReferenced(&$0.pointee)
    }
  }
}
