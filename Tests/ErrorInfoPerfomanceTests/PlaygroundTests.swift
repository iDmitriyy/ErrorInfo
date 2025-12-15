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
      for _ in 1...10 {
//        blackHole("")
      }
    }
    
//    let value = Optional(Optional(0)) as Any
    let value = 4 // Optional<Optional<Optional<Int>>>.some(.some(.some(5)))
//    let value = Optional<Optional<Int>>.some(.none) as Any
    
//    print("___ type: ", typeOfWrapped(any: 5))
//
//    print("___ type: ", typeOfWrapped(any: Optional<Optional<Optional<Int>>>.some(.some(.some(5)))))
//    print("___ type: ", typeOfWrapped(any: Optional<Optional<Optional<Int>>>.some(.some(.none))))
//    print("___ type: ", typeOfWrapped(any: Optional<Optional<Optional<Int>>>.some(.none)))
//    print("___ type: ", typeOfWrapped(any: Optional<Optional<Optional<Int>>>.none))
    
    do {
      let typeErasedString: Any = ""
      let typeErasedOptional: Any? = typeErasedString
      let any = typeErasedOptional as Any
      
//      print("___ type: ", typeOfWrapped(any: typeErasedString))
//      print("___ type: ", typeOfWrapped(any: typeErasedOptional))
//      print("___ type: ", typeOfWrapped(any: any))
      
//      print("___ type: ", typeOfWrapped(any: Optional<Any>.some("")))
      
//      print("___ type: ", typeOfWrapped(any: Optional<Any>.some("")))
//      print("___ type: ", typeOfWrapped(any: Optional<Optional<Optional<Any>>>.some(.some(.some("" as Any)))))
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
