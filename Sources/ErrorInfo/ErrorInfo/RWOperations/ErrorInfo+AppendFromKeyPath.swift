//
//  ErrorInfo+AppendProperties.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

// MARK: - Append from Instance's Properies

extension ErrorInfo {
  // Improvement: stringify-like macro for extracting the string name of value passed to `instance` arg
  // case .valueName then be useful only in contexts with shorthand args like $0.
  // But typically macro will be more convenient as there no need to duplicate binding name.
  // e.g. appendFromKeyPaths(of: address, keysPrefix: .valueName("address")) { ... } – need to manually write "address".
  // if `address` is renamed in sources, then "address" literal also needed to be changed manually, which is not what we want.
  // Macro also close the hole that valueName can be en empty string: .valueName(""). binding can not be empty
  
  /// Appends values from key paths of an instance to `ErrorInfo`, optionally prefixing keys.
  ///
  /// This method allows you to append properties of an instance to the `ErrorInfo` storage,
  /// converting the specified key paths into strings.
  /// You can choose to use either the type name or a custom prefix for the key paths.
  ///
  /// - Parameters:
  ///   - instance: The object whose properties will be appended to `ErrorInfo`.
  ///   - keysPrefix: An optional prefix for the key path string. Default is `.typeName`.
  ///   - origin: A source of potential collisions during the append operation.
  ///   - keys: A closure that returns the key paths of the instance's properties to be appended.
  ///
  /// # Example:
  /// ```swift
  /// var errorInfo = ErrorInfo()
  /// let person = Person(name: "John", age: 30)
  ///
  /// errorInfo.appendProperties(of: person) {
  ///   \Person.name
  ///   \Person.age
  /// }
  ///
  /// // The resulting keys will be prefixed with "Person" in the error info:
  /// errorInfo.keys // ["Person.name", "Person.age"]
  /// ```
  ///
  /// # Example with `keysPrefix` set to `nil`:
  /// ```swift
  /// var errorInfo = ErrorInfo()
  /// let car = Car(make: "Toyota", model: "Corolla", year: 2020)
  ///
  /// errorInfo.appendProperties(of: car, keysPrefix: nil) {
  ///   \Car.make; \Car.model; \Car.year
  /// }
  ///
  /// // The resulting keys will not be prefixed with "Car":
  /// errorInfo.keys // ["make", "model", "year"]
  /// ```
  public mutating func appendProperties<R, each V: ValueProtocol>(
    of instance: R,
    keysPrefix: KeyPathPrefixOption? = .typeName,
    origin: WriteProvenance.Origin,
    @ErrorInfoKeyPathsBuilder keys: () -> (repeat KeyPath<R, each V>),
  ) {
    let keyPaths = keys() // R.self
    
    for keyPath in repeat (each keyPaths) {
      let keyPathString: String = switch keysPrefix {
      case .typeName: ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath, withTypePrefix: true)
      case .custom(let name): name + "." + ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath, withTypePrefix: false)
      case nil: ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath, withTypePrefix: false)
      }
      
      let value = instance[keyPath: keyPath]
      
      withCollisionAndDuplicateResolutionAdd(
        optionalValue: value,
        shouldPreserveNilValues: true,
        duplicatePolicy: .defaultForAppending,
        forKey: keyPathString,
        keyOrigin: .keyPath,
        writeProvenance: .onAppend(origin: origin),
      )
    }
  }
  
  public mutating func appendProperties<R, each V: ValueProtocol>(
    of instance: R,
    keysPrefix: KeyPathPrefixOption? = .typeName,
    file: StaticString = #fileID,
    line: UInt = #line,
    @ErrorInfoKeyPathsBuilder keys: () -> (repeat KeyPath<R, each V>),
  ) {
    appendProperties(of: instance, keysPrefix: keysPrefix, origin: .fileLine(file: file, line: line), keys: keys)
  }
  
  // DEFERRED: - slow on release builds. 5 properties takes ~0.0004s.
  
  @resultBuilder
  public struct ErrorInfoKeyPathsBuilder {
    public static func buildBlock<R, each V: ValueProtocol>(_ values: repeat KeyPath<R, each V>) -> (repeat KeyPath<R, each V>) {
      let result = (repeat each values)
      return result
    }
  }
}
