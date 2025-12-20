//
//  PlaygroundTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 07/10/2025.
//

@_spi(PerfomanceTesting) import ErrorInfo
import Foundation
import Testing

struct PlaygroundTests {
  @Test func playground() throws {
    let count = 10
        
    var infos: [ErrorInfo] = []
    for index in 1...1000 {
      infos.append(["": 10, "20": "AAAA", "20": "AAAA", "20": "AAAA", "20": "AAAA"]) // , "20": "AAAA"
    }
    infos.shuffle()
    
    let output = performMeasuredAction(count: count) {
      for _ in 1...1_000 {
        for infoIndex in infos.indices {
          for element in infos[infoIndex] {
            blackHole(element)
          }
        }
      }
    }
    
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
    
    print("__playground: ", output.duration.asString(fractionDigits: 5)) // it takes ~25ms for 10 million of calls of empty blackHole(())
  } // test func end
}
