//
//  ErrorInfo+PartialCollection.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 07/10/2025.
//

extension ErrorInfo {
  public var count: Int { _storage.count }
  
  public var isEmpty: Bool { _storage.isEmpty }
}
