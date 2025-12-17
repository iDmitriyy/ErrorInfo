//
//  ErrorInfo+CustomStringConvertible.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

extension ErrorInfo: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { String(describing: _storage) }
  
  // FIXME: use @DebugDescription macro
  public var debugDescription: String { String(reflecting: _storage) }
}
