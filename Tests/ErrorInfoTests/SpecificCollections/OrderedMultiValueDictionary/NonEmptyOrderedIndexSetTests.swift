//
//  NonEmptyOrderedIndexSetTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/10/2025.
//

@testable import ErrorInfo
import Testing

// MARK: 3. Internal NonEmptyOrderedIndexSet Tests

struct NonEmptyOrderedIndexSetTests {
  @Test func `test SingleToMultiple Transition`() {
    var indexSet: NonEmptyOrderedIndexSet = .single(index: 1)
    indexSet.insert(3)

    switch indexSet._variant {
    case .single:
      Issue.record("Expected to transition to .multiple")
    case .multiple(let indices):
      #expect(indices.apply(Array.init) == [1, 3])
    }
  }

  @Test func `test MultipleInsertPreserves Order`() {
    var indexSet: NonEmptyOrderedIndexSet = .single(index: 2)
    indexSet.insert(4)
    indexSet.insert(6)
    indexSet.insert(6)

    #expect(indexSet.apply(Array.init) == [2, 4, 6])
  }
}
