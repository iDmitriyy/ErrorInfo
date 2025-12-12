//
//  LegacyErrorInfo+CustomStringConvertible.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 15/10/2025.
//

extension LegacyErrorInfo: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { String(describing: _storage) }
  
  public var debugDescription: String { String(reflecting: _storage) }
}
