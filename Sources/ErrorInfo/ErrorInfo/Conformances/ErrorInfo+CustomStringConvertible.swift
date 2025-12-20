//
//  ErrorInfo+CustomStringConvertible.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

extension ErrorInfo: CustomDebugStringConvertible {  
  public var debugDescription: String {  _storage.debugDescription }
}
