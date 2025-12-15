//
//  LegacyErrorInfo+Record.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 12/12/2025.
//

extension LegacyErrorInfo {
  internal struct Record {
    let taggedValue: CollisionTaggedValue<Value, CollisionSource>
    let keyOrigin: KeyOrigin
  }
}
