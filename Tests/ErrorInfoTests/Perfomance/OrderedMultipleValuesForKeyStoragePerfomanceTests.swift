//
//  OrderedMultipleValuesForKeyStoragePerfomanceTests.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 06/10/2025.
//

@testable import ErrorInfo
import OrderedCollections
import Testing

struct OrderedMultipleValuesForKeyStoragePerfomanceTests {
  private let elements = 1...50000
  
  @Test func subscriptInsertionUniqueKeysWithSingleValue() {
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
    
    // ~1.5 slower vs OrderedDictionary
    // ~9.5x slower vs Swift.Dictionary
    // TODO: compare on optimized build
    let orderedMultiValueStorageOutput = performMeasuredAction(count: count) {
      var dict = OrderedMultipleValuesForKeyStorage<Int, Int>()
      for element in elements {
        dict.append(key: element, value: element, collisionSource: .onSubscript)
      }
      return dict
    }
    
    print(dictOutput.duration, orderedDictOutput.duration, orderedMultiValueStorageOutput.duration)
  }
}
