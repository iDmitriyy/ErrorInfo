//
//  main.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 28/12/2025.
//

import ErrorInfo

@main struct Main {
  static func main() {
    print("____________ ________ -------------")
    let params = [(1, true), (2, true), (2, false), (3, true), (3, false)]
    let policies = [ValueDuplicatePolicy.allowEqual, .rejectEqual, .allowEqualWhenOriginDiffers]
    
    for param in params {
      for policy in policies {
        ErrorInfoAddValueTests().`add value`(params: param, duplicatePolicy: policy)
      }
    }
  }
}
