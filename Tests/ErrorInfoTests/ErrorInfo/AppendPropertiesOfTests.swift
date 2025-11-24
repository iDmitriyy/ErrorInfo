//
//  AppendFromKeyPathsTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/10/2025.
//

@testable import ErrorInfo
import Testing

struct AppendPropertiesOfTests {
  @Test func appendProperties() throws {
    var info = ErrorInfo()
    
    struct Product {
      let name: String
      let amount: Double
    }
    
    let product = Product(name: "Laptop", amount: 1)
    
    info.appendProperties(of: product, keysPrefix: .valueName("product")) {
      \Product.name; \Product.amount
    }
    
    // ...
  }
}
