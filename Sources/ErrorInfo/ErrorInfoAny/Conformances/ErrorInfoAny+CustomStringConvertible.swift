//
//  ErrorInfoAny+CustomStringConvertible.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 20/12/2025.
//

extension ErrorInfoAny: CustomDebugStringConvertible {
  public var debugDescription: String { _storage.debugDescription }
}
