//
//  ErrorInfo+CollectWithKeyPath.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

// MARK: - Collect values from KeyPath

extension ErrorInfo {
  public enum KeyPathPrefixKind {
    case type
    case valueName(_ name: String)
  }
  
  public mutating func appendFromKeyPaths<R, each V: ValueType>(of instance: R,
                                                                withKeysPrefix keysPrefixKind: KeyPathPrefixKind?,
                                                                @ErrorInfoKeyPathsBuilder keys: () -> (repeat KeyPath<R, each V>)) {
    let keyPaths = keys() // R.self
    
    for keyPath in repeat (each keyPaths) {
      // TODO: keyKind – case keyPath
      let key: String = switch keysPrefixKind {
      case .type: ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath, withTypePrefix: true)
      case .valueName(let name): name + "." + ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath, withTypePrefix: false)
      case nil: ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath, withTypePrefix: false)
      }
      
      let value = instance[keyPath: keyPath]
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
