//
//  ErrorInfo+AppendContentsOf.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

// MARK: - Append ContentsOf

extension ErrorInfo {
  public mutating func append(contentsOf sequence: some Sequence<(String, ValueExistential)>,
                              duplicatePolicy: ValueDuplicatePolicy,
                              collisionSource collisionOrigin: CollisionSource.Origin = .fileLine()) {
    for (dynamicKey, value) in sequence {
      _add(key: dynamicKey,
           keyOrigin: .dynamic,
           value: value,
           preserveNilValues: true, // has no effect here
           duplicatePolicy: duplicatePolicy,
           collisionSource: .onSequenceConsumption(origin: collisionOrigin))
    }
  }
}
