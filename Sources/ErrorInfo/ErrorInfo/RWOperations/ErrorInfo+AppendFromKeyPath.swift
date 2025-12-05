//
//  ErrorInfo+AppendProperties.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

// MARK: - Collect values from KeyPath

extension ErrorInfo {
  public enum KeyPathPrefix {
    case typeName
    case customName(_ name: String)
  }
  
  // Improvement:
  // Improvement: stingify-like macro for extrating the string name of value passed to `instance` arg
  // case .valueName then be useful only in contexts with shortand args like $0.
  // But typically macro will be more convenient as there no need to duplacte binding name.
  // e.g. appendFromKeyPaths(of: address, keysPrefix: .valueName("address")) { ... } – need to maanually write "address".
  // if `address` is renamed in sources, then "address" literal alsso needed to be cnhaged manualy, which is not what we want.
  // Macro also closses the hole that valueName can be en empty string: .valueName(""). binding can not be empty
  
  public mutating func appendProperties<R, each V: ValueType>(
    of instance: R,
    keysPrefix: KeyPathPrefix? = .typeName,
    @ErrorInfoKeyPathsBuilder keys: () -> (repeat KeyPath<R, each V>),
  ) {
    let keyPaths = keys() // R.self
    
    for keyPath in repeat (each keyPaths) {
      let keyPathString: String = switch keysPrefix {
      case .typeName: ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath, withTypePrefix: true)
      case .customName(let name): name + "." + ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath, withTypePrefix: false)
      case nil: ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath, withTypePrefix: false)
      }
      
      let value = instance[keyPath: keyPath]
      
      _add(key: keyPathString,
           keyOrigin: .keyPath,
           value: value,
           preserveNilValues: true,
           duplicatePolicy: .default,
           collisionSource: .onAppend)
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
