//
//  LegacyErrorInfo+Record.swift
//  ErrorInfo
//
//  Created by tmp on 12/12/2025.
//

extension LegacyErrorInfo {
  internal struct Record {
    let taggedValue: CollisionTaggedValue<Value, CollisionSource>
    let keyOrigin: KeyOrigin
  }
}
