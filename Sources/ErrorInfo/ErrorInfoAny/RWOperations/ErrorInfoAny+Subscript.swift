//
//  ErrorInfoAny+Subscript.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

extension ErrorInfoAny {  
  // MARK: - Read access Subscript
  
  public subscript(_ literalKey: StringLiteralKey) -> (ValueExistential)? {
    lastValue(forKey: literalKey)
  }
  
  // MARK: - Mutating subscript
  
  public subscript<V>(_ literalKey: StringLiteralKey) -> V? {
    @available(*, unavailable, message: "This is a set-only subscript")
    get {
      lastValue(forKey: literalKey) as? V
    }
    set {
      _add(key: literalKey.rawValue,
           keyOrigin: literalKey.keyOrigin,
           value: newValue,
           preserveNilValues: true,
           duplicatePolicy: .defaultForAppending,
           writeProvenance: .onSubscript(origin: nil)) // providing origin for a single key-value is an overhead for binary size
    }
  }
}
