//
//  AppendFromKeyPathsTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/10/2025.
//

@testable import ErrorInfo
import Testing

struct AppendPropertiesOfTests {
  private let product = Product(name: "MacBook Pro", amount: 1)
  
  @Test func noPrefix() throws {
    var info = ErrorInfo()
    
    info.appendProperties(of: product, keysPrefix: nil) {
      \Product.name; \Product.amount
    }
    
    #expect(info["name"] as? String == product.name)
    #expect(info["amount"] as? Double == product.amount)
  }
  
  @Test func defaultsTypeName() throws {
    var info = ErrorInfo()
    
    info.appendProperties(of: product) {
      \Product.name; \Product.amount
    }
    
    #expect(info["Product.name"] as? String == product.name)
    #expect(info["Product.amount"] as? Double == product.amount)
  }
  
  @Test func customName() throws {
    var info = ErrorInfo()
    
    info.appendProperties(of: product, keysPrefix: .custom("laptop")) {
      \Product.name; \Product.amount
    }
    
    #expect(info["laptop.name"] as? String == product.name)
    #expect(info["laptop.amount"] as? Double == product.amount)
  }
  
  private struct Product {
    let name: String
    let amount: Double
  }
}
