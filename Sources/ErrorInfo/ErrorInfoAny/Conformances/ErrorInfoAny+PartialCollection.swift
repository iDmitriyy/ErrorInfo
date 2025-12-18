//
//  ErrorInfoAny+PartialCollection.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

extension ErrorInfoAny {
  @_transparent public var count: Int { _storage.count }
  
  @_transparent public var isEmpty: Bool { _storage.isEmpty }
}
