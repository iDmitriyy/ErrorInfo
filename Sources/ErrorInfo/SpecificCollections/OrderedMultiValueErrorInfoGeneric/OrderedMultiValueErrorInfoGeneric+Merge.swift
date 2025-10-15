//
//  OrderedMultiValueErrorInfoGeneric+Merge.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 07/10/2025.
//

extension OrderedMultiValueErrorInfoGeneric {
  public mutating func mergeWith(other _: Self,
                                 omitEqualValues _: Bool,
                                 mergeOrigin _: @autoclosure () -> CollisionSource.MergeOrigin = .fileLine()) {
    // use update(value:, forKey:) if it is fster than checking hasValue() + append
  }
}
