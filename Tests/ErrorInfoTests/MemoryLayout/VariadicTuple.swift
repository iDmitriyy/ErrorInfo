//
//  VariadicTuple.swift
//  ErrorInfo
//
//  Created by tmp on 06/10/2025.
//

struct VariadicTuple<each T> {
  let elements: (repeat each T)
  
  init(_ elements: repeat each T) {
    self.elements = (repeat each elements)
  }
}
