//
//  ErrorInfoAny+MergeSelf.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/01/2026.
//

// MARK: - Protocol Requirement Imp

extension ErrorInfoAny {
  public static func mergeTo(recipient: inout Self,
                             donator: Self,
                             origin: @autoclosure () -> WriteProvenance.Origin) {
    BackingStorage.mergeTo(recipient: &recipient._storage, donator: donator._storage, origin: origin())
  }
}
