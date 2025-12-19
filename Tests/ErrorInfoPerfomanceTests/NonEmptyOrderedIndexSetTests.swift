//
//  NonEmptyOrderedIndexSetTests.swift
//  ErrorInfo
//
//  Created by tmp on 19/12/2025.
//

@_spi(PerfomanceTesting) import ErrorInfo
import NonEmpty
import OrderedCollections
import Testing

struct NonEmptyOrderedIndexSetTests {
  @Test func playground() throws {
    let count = 100
    
     let initial = NonEmptyOrderedIndexSet.single(index: 0)
//    let initial = mutate(value: NonEmptyOrderedIndexSet.single(index: 0)) { $0.insert(1) }
    
    let output = performMeasuredAction(count: count) {
      for index in 1...10000 {
        var initial = initial
        initial.insert(index)
//        blackHole(NonEmptyOrderedIndexSet.single(index: index))
      }
    }
    // OrderedSet<Int>.init(uncheckedUniqueElements)
    print("__nonEmptyIndexSet: ", output.duration.asString(fractionDigits: 5)) // it takes ~25ms for 10 million of calls of empty blackHole(())
    
    // .single(index: 0)
    //
    
    // .multi
    //
    }
  
  @Test func insertion() throws {
    let orderedSet = mutate(value: OrderedSet<Int>()) { $0.append(0) }
    let nonEmptyIndexSet = mutate(value: NonEmptyOrderedIndexSet.single(index: 0)) { $0.insert(1) } // trigger creation of heap backed set
    
    let count = 1000
    
    let orderedSetOutput = performMeasuredAction(count: count) {
      var orderedSet = orderedSet
      for index in 1...500 {
        orderedSet.append(index)
      }
    }
    
    let nonEmptyIndexSetOutput = performMeasuredAction(count: count) {
      var nonEmptyIndexSet = nonEmptyIndexSet
      for index in 1...500 {
        nonEmptyIndexSet.insert(index)
      }
    }
    
    #expect(nonEmptyIndexSetOutput.duration == orderedSetOutput.duration) // +2%
  }
}
