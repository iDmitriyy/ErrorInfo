//
//  ErrorInfo+RemoveAll.swift
//  ErrorInfo
//
//  Created by tmp on 24/11/2025.
//

// MARK: - Remove All

extension ErrorInfo {
  internal mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _storage.removeAll(keepingCapacity: keepCapacity)
  }
}
