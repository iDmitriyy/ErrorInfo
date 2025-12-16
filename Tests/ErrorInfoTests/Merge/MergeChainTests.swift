//
//  MergeChainTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 26/11/2025.
//

import Collections
@testable import ErrorInfo
import Testing

struct MergeChainTests {
  @Test func basic() throws {
    typealias Dict = OrderedDictionary<String, any ErrorInfoValueType>
    typealias ODError = ErrorStub<Dict>
    
    let error0 = ODError(code: 2, shortDomain: "NE",
                         info: ["value": 0, "count": 0])
    
    let error1 = ODError(code: 2, shortDomain: "NE",
                         info: ["count": 1, "url": "https://192.168.0.1"])
    
    let error2 = ODError(code: 14, shortDomain: "ME",
                         info: ["id": 2])
    
    let error3 = ODError(code: 2, shortDomain: "NE",
                         info: ["id": 3, "count": 3, "url": "https://192.168.0.3"])
    
    let error4 = ODError(code: 0, shortDomain: "NE2",
                         info: ["id": 4, "status": 4])
    
    let errorsChain = [error4, error3, error2, error1, error0]
    
    let expected: Dict = [ // OrderedDictionary can contain duplicated keys, use KeyValuePairs
      "id": "4",
//      "status": 4,
//      
//      "id": 3,
//      "count": 3,
//      "url": "https://192.168.0.3",
//      
//      "id": 2,
//      
//      "count": 1,
//      "url": "https://192.168.0.1",
//      
//      "value": 0,
//      "count": 0,
    ]
  }
}

struct ErrorStub<Info> {
  let code: Int
  let shortDomain: String
  let errorInfo: Info
  
  init(code: Int, shortDomain: String, info: Info) {
    self.code = code
    self.shortDomain = shortDomain
    errorInfo = info
  }
}
