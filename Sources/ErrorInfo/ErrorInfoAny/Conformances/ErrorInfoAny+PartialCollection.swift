//
//  ErrorInfoAny+PartialCollection.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

extension ErrorInfoAny {
  public var count: Int { _storage.count }
  
  public var isEmpty: Bool { _storage.isEmpty }
}
