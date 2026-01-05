//
//  ABCTest.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 05/01/2026.
//

import ErrorInfo
import XCTest

final class ABCTests: XCTestCase {
  
  func testAbc() {
//    let info = ErrorInfo()
//    info._storage
    var dict = Dictionary<String, ErrorInfo.ValueExistential>(minimumCapacity: 2)
    dict["name"] = "name"
    dict["id"] = 0
    
    measure {
      for _ in 0..<10_000_000 {
        blackHole(dict["id"])
      }
    }
  }
}
