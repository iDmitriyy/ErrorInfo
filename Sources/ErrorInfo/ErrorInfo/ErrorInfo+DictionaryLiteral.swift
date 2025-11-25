//
//  ErrorInfo+DictionaryLiteral.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 26/07/2025.
//

// MARK: Expressible By Dictionary Literal

extension ErrorInfo: ExpressibleByDictionaryLiteral {
  public typealias Value = (any ErrorInfoValueType)?
  public typealias Key = String
  // FIXME: can optional ErrorInfoValueType be used without conflict with ErrorInfoIterable protocol
  // Alternative: if optionals are impossible for DictionaryLiteral usage, then add functionBuilder initialization that allows
  // optional values
  
  public init(dictionaryLiteral elements: (String, Value)...) {
    self.init()
    // TODO: OrderedMultipleValuesDictionaryLiteral(dictionaryLiteral: elements) or appropriate init
    // TODO: try reserve capacity. perfomance tests
    // Make Key = ErronInfoLiteralKey instead of String
    
    for (key, value) in elements {
//      if let value {
//        add1(value)
//      }
//      
//      add2(value)
      // FIXME: 
//      self._add(key: key,
//                value: value,
//                preserveNilValues: true,
//                insertIfEqual: true,
//                addTypeInfo: .default,
//                collisionSource: .onCreateWithDictionaryLiteral)
    }
    
    
  }
  
//  func add1<T: ErrorInfoValueType>(_ v: T) {
//    
//  }
//  
//  func add2<T: ErrorInfoValueType>(_ v: T?) {
//    
//  }
}
