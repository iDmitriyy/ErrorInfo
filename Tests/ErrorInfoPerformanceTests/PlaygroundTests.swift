//
//  PlaygroundTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 07/10/2025.
//

@_spi(PerformanceTesting) import ErrorInfo
import Foundation
import OrderedCollections
import Testing

struct PlaygroundTests {
  @Test func playground() throws {
    let count = 10
        
    let dict: OrderedDictionary<String, String> = [
      "dcdfdsdsfd": "dsf2sdfsdf",
      "dcdfdsdsfd2": "dsf1sdfsdf",
      "dcdfdsdsf3": "dsf4sdfsdf",
      "dcdfdsdsf4": "dsf2rdfsdf",
      "dcdfdsdsf5": "dsf2rdfqdf",
    ]
    
    let output = performMeasuredAction(count: count) {
      for index in 1...100_000 {
        blackHole(index)
      }
    }
    print("__playground: ", output.duration.asString(fractionDigits: 2)) // it takes ~25ms for 10 million of calls of empty blackHole(())
    
    // __playground:  331 transitionedFrom0
    // __playground:  315 transitionedFrom1
    // __playground:  315 transitionedFrom2
    // __playground:  439 transitionedFrom3
    
    // lastRecorded(forKey:) 1 value
    // __playground:  1351.15592 imp fullInfo(forKey:
    // __playground:  934.76617 imp firstSomeValue(forKey:
    
    // lastRecorded(forKey:) 2 values
    // __playground:  4387.46592 imp fullInfo(forKey:
    // __playground:  3034.21750 imp firstSomeValue(forKey:
    
    // firstValue(forKey:) 1 value
    // __playground:  1923.99688 allRecordsForKey iteration
    // __playground:  1328.89642 allRecordsForKey.indices
    // __playground:  1118.80925 – fast path with if let without for loop
    
    // firstValue(forKey:) 2 values (value at start)
    // __playground:  3390.59883 allRecordsForKey iteration
    // __playground:  3033.20338 allRecordsForKey.indices
    // __playground:  2980.96275 – fast path with if let without for loop
    
    // firstValue(forKey:) 2 values (nil at start)
    // __playground:  4220.67258 allRecordsForKey iteration
    // __playground:  3628.39821 allRecordsForKey.indices
    // __playground:  3620.53942 – fast path with if let without for loop
    
    // lastValue(forKey:) 1 value
    // __playground:  2418.18941 allRecordsForKey.reversed()
    // __playground:  1326.62396 allRecordsForKey.indices.reversed()
    // __playground:  1114.40604 __playground:  1118.80925
    
    // lastValue(forKey:) 2 values (value at end)
    // __playground:  3674.42858 allRecordsForKey.reversed()
    // __playground:  3011.19642 allRecordsForKey.indices.reversed()
    // __playground:  2919.35504 – fast path with if let without for loop
    
    // lastValue(forKey:) 2 values (nil at end)
    // __playground:  4200.32629 allRecordsForKey.reversed()
    // __playground:  3470.00304 allRecordsForKey.indices.reversed()
    // __playground:  3513.45225 – fast path with if let without for loop
    
    // .allKeys
    // __playground:  1117.44792
    // __playground:  971.86592
    
    // .keys
    // __playground:  1119.86362
    // __playground:  987.67208
    
    // 1 element iteration
    // __playground:  1878.61166
    // __playground:  1624.01646 // @inline(__always) makeIterator()
    // __playground:  1589.58529 // @inline(__always) next()
    // __playground:  1575.46502 // continue change to return
    
    // 2 elements iteration
    // __playground:  3106.26337
    // __playground:  2982.85158
    // __playground:  2923.02788
    // __playground:  2888.82771
        
    // subscript(position: Int)
    // __playground:  511.07600 - non inlining
    // __playground:  820.74125 - inlined in ErrorInfo
    // __playground:  829.90150 - inlined in GenericInfo
    // __playground:  368.27838 - inline OrderedMultipleValuesForKeyStorage
    
    // startIndex
    // __playground:  136.69942
    
    // Count
    // __playground:  276.77834
    // __playground:  138.80996
    
    // isEmpty
    // __playground:  274.04075
    // __playground:  132.46879
    
    // __playground:  212.98750
    // __playground:  165.03579
    
//    let output = performMeasuredAction(count: count) {
//      for _ in 1...1_000_000 {
//        blackHole("")
//      }
//    }
    
//    print(AnyHashable(0) == AnyHashable(0))
//    print(AnyHashable(Optional(Optional(0))) == AnyHashable(0))
//    print(AnyHashable(Optional<Optional<Int>>.some(.none)) == AnyHashable(Optional<Int>.none))
//    print(AnyHashable(Optional<Optional<Int>>.none) == AnyHashable(Optional<Int>.none))
//    print(AnyHashable(Optional(Optional(0))) == AnyHashable(""))
//    print(AnyHashable(Optional<Int>.none) == AnyHashable(Optional<String>.none))
  } // test func end
}
