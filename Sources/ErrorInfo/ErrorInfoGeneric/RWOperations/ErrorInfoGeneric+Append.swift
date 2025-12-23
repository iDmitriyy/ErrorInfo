//
//  ErrorInfoGeneric+Append.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

extension ErrorInfoGeneric {}

// MARK: - Append

extension ErrorInfoGeneric where RecordValue: Equatable {
  /// Instead of subscript overload with `String` key to prevent pollution of autocomplete for `ErronInfoLiteralKey` by tons of String methods.
  mutating func append(key: Key, keyOrigin: KeyOrigin, someValue newValue: RecordValue) {
    _add(key: key,
         keyOrigin: keyOrigin,
         someValue: newValue,
         duplicatePolicy: .defaultForAppending,
         writeProvenance: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead for binary size
  }
}

extension ErrorInfoGeneric where RecordValue: Equatable & ErrorInfoOptionalRepresentable {
  mutating func append(key: Key,
                       keyOrigin: KeyOrigin,
                       optionalValue: RecordValue.Wrapped?,
                       typeOfWrapped: RecordValue.TypeOfWrapped,
                       preserveNilValues: Bool) {
    _add(key: key,
         keyOrigin: keyOrigin,
         optionalValue: optionalValue,
         typeOfWrapped: typeOfWrapped,
         preserveNilValues: preserveNilValues,
         duplicatePolicy: .defaultForAppending,
         writeProvenance: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead for binary size
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: Append IfNotNil

extension ErrorInfoGeneric where RecordValue: Equatable {
  mutating func appendIfNotNil(someValue: RecordValue?,
                               forKey key: Key,
                               keyOrigin: KeyOrigin,
                               duplicatePolicy: ValueDuplicatePolicy) {
    guard let someValue else { return }
    
    _add(key: key,
         keyOrigin: keyOrigin,
         someValue: someValue,
         duplicatePolicy: duplicatePolicy,
         writeProvenance: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead for binary size
  }
}

extension ErrorInfoGeneric where RecordValue: Equatable & ErrorInfoOptionalRepresentable {
  mutating func appendIfNotNil(optionalValue: RecordValue.Wrapped?,
                               typeOfWrapped: RecordValue.TypeOfWrapped,
                               forKey key: Key,
                               keyOrigin: KeyOrigin,
                               duplicatePolicy: ValueDuplicatePolicy) {
    guard let value = optionalValue else { return }
    
    _add(key: key,
         keyOrigin: keyOrigin,
         optionalValue: value,
         typeOfWrapped: typeOfWrapped,
         preserveNilValues: true, // has no effect in this func, unwrapped above
         duplicatePolicy: duplicatePolicy,
         writeProvenance: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead for binary size
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: Append ContentsOf

//extension ErrorInfoGeneric {
//  // TODO: - RecordValue & RecordValue.Wrapped are really existentials, need make pissoble to append generic values, not existentials
//  mutating func append(contentsOf sequence: some Sequence<(Key, RecordValue)>,
//                       duplicatePolicy: ValueDuplicatePolicy,
//                       origin: CollisionSource.Origin) {
//    for (key, someValue) in sequence {
//      _add(key: key,
//           keyOrigin: .dynamic,
//           someValue: someValue,
//           duplicatePolicy: duplicatePolicy,
//           writeProvenance: .onSequenceConsumption(origin: origin))
//    }
//  }
//}
//
//extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentable {
//  mutating func append(contentsOf sequence: some Sequence<(Key, RecordValue.Wrapped)>,
//                       typeOfWrapped: RecordValue.TypeOfWrapped,
//                       duplicatePolicy: ValueDuplicatePolicy,
//                       origin: CollisionSource.Origin) {
//
//    for (key, nonNilValue) in sequence {
//      _add(key: key,
//           keyOrigin: .dynamic,
//           optionalValue: nonNilValue,
//           typeOfWrapped: typeOfWrapped, // TODO: - typeOfWrapped | one for all elements?
//           preserveNilValues: true, // has no effect in this func
//           duplicatePolicy: duplicatePolicy,
//           writeProvenance: .onSequenceConsumption(origin: collisionOrigin))
//    }
//  }
//}
