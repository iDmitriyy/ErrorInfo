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

@inline(never)
public func genericTest<T>(value: T, closure: (T?) -> Void) {
  closure(value)
}

struct PlaygroundTests {
  @Test func playground() throws {
    let count = 10000
    let key1 = "key"
    let key2 = "key2"
//    let output = performMeasuredAction(count: count) {
//      for index in 1...100_000 {
//        blackHole(index)
//      }
//    }
    
    if #available(macOS 26.0, *) {
      genericTest(value: 2) { value in
        let value = 5
//        let overhead = performMeasuredAction(iterations: count) { _ in
//          InlineArray<1000, ErrorInfo> { index in ErrorInfo.empty }
//        } measure: { array in
//          for _ in 1...10 {
//            for index in array.indices {
//              blackHole(array[index])
//            }
//          }
//        }
        
//        let baseline = performMeasuredAction(iterations: count) { _ in
//          InlineArray<1000, ErrorInfo> { index in ErrorInfo() }
//        } measure: { array in
//          for _ in 1...10 {
//            for index in array.indices {
//               array[index]._addValue_Test_1(value, duplicatePolicy: .allowEqual, forKey: key)
//            }
//          }
//        }
        
        let measured = performMeasuredAction(iterations: count) { _ in
          InlineArray<1000, ErrorInfo> { index in
            ErrorInfo()
//            [.apiEndpoint: index, .base64String: index] as ErrorInfo
          }
        } measure: { array in
          for index in array.indices {
            array[index].appendIfNotNil(value, forKey: key1)
//               array[index]._addValue_Test_2(.fromOptional(value), duplicatePolicy: .allowEqual, forKey: key)
          }
        }
        
//        let measurements = collectMeasurements(overhead: {overhead}, baseline: {baseline}, measured: {measured})
        
        // print(measurements.adjustedRatio)
        print(measured.medianDuration.inMicroseconds)
        // appendIfNotNil
        // 1689 1640
        // 1623 1634 (inline)
        // 1333
        // 131 130 132
        // 131 131 132
        
        // merge
        // 458 458 458 - merged(with:)
        // 7661 7554 7569 – struct with inlining
        // 7691 7771 7668 - struct no inlining
        // 8204 8201
      }
    }
    
    // print("__playground: ", output.duration.asString(fractionDigits: 2)) // it takes ~25ms for 10 million of calls of empty blackHole(())
    
    // dict hasValueForKey
    
    // __playground:  331 transitionedFrom0
    // __playground:  315 transitionedFrom1
    // __playground:  315 transitionedFrom2
    // __playground:  439 transitionedFrom3
    
    // lastRecorded(forKey:) 1 value
    // __playground:  1351.15592 imp allRecords(forKey:
    // __playground:  934.76617 imp firstSomeValue(forKey:
    
    // lastRecorded(forKey:) 2 values
    // __playground:  4387.46592 imp allRecords(forKey:
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

// hasValue(forKey:)                          byIndex     byKeys     byNil              .
// OrderedDictionary<String, String>            326         315       349               .
// OrderedDictionary<String, LargeStruct>       314         296      4484               .
// OrderedDictionary<String, Int>               328         313       353               .
// OrderedDictionary<Int, Int>                  377         348       395               .
// OrderedDictionary<String, ___________>       ___         ___      ____               .
//
// Swift.Dictionary<String, String>            1788        1285      1782               .
// Swift.Dictionary<String, LargeStruct>       1794        1293      6634               .
// Swift.Dictionary<String, Int>               1794        1296      1786               .
// Swift.Dictionary<Int, Int>                   865         866       865               .
// Swift.Dictionary<String, ___________>       ____        ____      ____               .
// byIndex – index(forKey: key) != nil
//  byKeys – keys.contains(key)
//   byNil – self[key] != nil
