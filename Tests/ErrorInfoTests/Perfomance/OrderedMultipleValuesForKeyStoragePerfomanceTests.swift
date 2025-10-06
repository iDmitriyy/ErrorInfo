//
//  OrderedMultipleValuesForKeyStoragePerfomanceTests.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 06/10/2025.
//

@testable import ErrorInfo
import OrderedCollections
import Testing

// !rewrite
struct OrderedMultipleValuesForKeyStoragePerfomanceTests {
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
      var dict = OrderedMultipleValuesForKeyStorage<Int, Int, StringBasedCollisionSource>()
      for element in elements {
        dict.append(key: element, value: element, collisionSource: .onSubscript)
      }
      return dict
    }
    
    print(dictOutput.duration, orderedDictOutput.duration, orderedMultiValueStorageOutput.duration)
  }
  
  // TODO: + compare OrderedMultiValueErrorInfoGeneric
  
  @Test func getSingleValueForKey() {
    // measure OrderedMultipleValuesForKeyStorage.ValuesForKey overhead
  }
  
  @Test func hasValueForKey() {
    
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
}
