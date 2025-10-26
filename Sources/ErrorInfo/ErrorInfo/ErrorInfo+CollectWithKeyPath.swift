//
//  ErrorInfo+CollectWithKeyPath.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

// MARK: - Collect values from KeyPath

extension ErrorInfo {
  
  public mutating func appendFromKeyPaths<R, each V: ValueType>(of instance: R,
                                                                withTypePrefix: Bool,
                                                                @ErrorInfoKeyPathsBuilder keys: () -> (repeat KeyPath<R, each V>)) {
    let keyPaths = keys() // R.self
    
    for keyPath in repeat (each keyPaths) {
      let value = instance[keyPath: keyPath]
      let key = ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath, withTypePrefix: withTypePrefix)
      self[key] = value
    }
  }
    
  @resultBuilder
  public struct ErrorInfoKeyPathsBuilder {
    public static func buildBlock<R, each V: ErrorInfoValueType>(_ values: repeat KeyPath<R, each V>) -> (repeat KeyPath<R, each V>) {
      let result = (repeat each values)
      return result
    }
  }
}
