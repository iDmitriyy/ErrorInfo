//
//  ErrorInfoGeneric+MergeSelf.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

extension ErrorInfoGeneric where RecordValue: Equatable {
  @inlinable
  @inline(__always)
  public static func mergeTo(recipient: inout Self,
                             donator: Self,
                             origin: @autoclosure () -> WriteProvenance.Origin) {
    for recordIndex in donator.indices {
      // iteration over indices and access by index is faster than iteration over elements
      let (key, annotatedRecord) = donator[recordIndex]
      recipient.withCollisionAndDuplicateResolutionAdd(
        record: annotatedRecord.record,
        forKey: key,
        duplicatePolicy: .allowEqual,
        writeProvenance: annotatedRecord.collisionSource ?? .onMerge(origin: origin()),
      )
    }
  }
}
