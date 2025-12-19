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
    
    let output = performMeasuredAction(count: count) {
      for _ in 1...1_000_000 {
        blackHole("")
      }
    }
    
//    print(AnyHashable(0) == AnyHashable(0))
//    print(AnyHashable(Optional(Optional(0))) == AnyHashable(0))
//    print(AnyHashable(Optional<Optional<Int>>.some(.none)) == AnyHashable(Optional<Int>.none))
//    print(AnyHashable(Optional<Optional<Int>>.none) == AnyHashable(Optional<Int>.none))
//    print(AnyHashable(Optional(Optional(0))) == AnyHashable(""))
//    print(AnyHashable(Optional<Int>.none) == AnyHashable(Optional<String>.none))
    
    print("__playground: ", output.duration.asString(fractionDigits: 5)) // it takes ~25ms for 10 million of calls of empty blackHole(())
  } // test func end
}

extension Double {
  public func asString(fractionDigits: UInt8) -> String {
    String(format: "%.\(fractionDigits)f", self)
  }
}
