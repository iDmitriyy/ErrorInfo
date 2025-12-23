//
//  ErrorInfoAny+AppendContentsOf.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

// MARK: - Append ContentsOf

extension ErrorInfoAny {
  public mutating func append<V>(contentsOf sequence: some Sequence<(String, V)>,
                                 duplicatePolicy: ValueDuplicatePolicy,
                                 file: StaticString = #fileID,
                                 line: UInt = #line) {
    append(contentsOf: sequence, duplicatePolicy: duplicatePolicy, writeProvenance: .fileLine(file: file, line: line))
  }
  
  public mutating func append<V>(contentsOf sequence: some Sequence<(String, V)>,
                                 duplicatePolicy: ValueDuplicatePolicy,
                                 writeProvenance: WriteProvenance.Origin) {
    for (dynamicKey, value) in sequence {
      _add(key: dynamicKey,
           keyOrigin: .fromCollection,
           value: value,
           preserveNilValues: true, // has no effect here
           duplicatePolicy: duplicatePolicy,
           writeProvenance: .onSequenceConsumption(origin: writeProvenance))
    }
  }
}
