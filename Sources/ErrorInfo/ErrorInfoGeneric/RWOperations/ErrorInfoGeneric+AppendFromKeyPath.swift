//
//  ErrorInfoGeneric+AppendProperties.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

/// This enum allows you to specify how the key path string should be prefixed when it's converted
/// to a string representation. You can use either the type's name or a custom name.
///
/// - `typeName`: Uses the type's name as a prefix.
/// - `customName`: Allows you to provide a custom prefix string, like name of an instance's property.
public enum KeyPathPrefixOption {
  case typeName
  case customName(_ name: String)
}

extension ErrorInfoGeneric where Key == String, GValue: ErrorInfoOptionalRepresentable {
  mutating func _appendProperty<R, V>(of instance: R,
                                      keyPath: KeyPath<R, V>,
                                      keysPrefix: KeyPathPrefixOption?,
                                      typeOfWrapped: GValue.TypeOfWrapped,
                                      converToExistential: (V) -> GValue.Wrapped,
                                      ollisionSource collisionOrigin: @autoclosure () -> CollisionSource.Origin) {
    let keyPathString: String = switch keysPrefix {
    case .typeName: ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath, withTypePrefix: true)
    case .customName(let name): name + "." + ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath, withTypePrefix: false)
    case nil: ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath, withTypePrefix: false)
    }
    
    let value = instance[keyPath: keyPath]
    let valueExistential = converToExistential(value)
    
    _add(key: keyPathString,
         keyOrigin: .keyPath,
         optionalValue: valueExistential,
         typeOfWrapped: typeOfWrapped,
         preserveNilValues: true,
         duplicatePolicy: .defaultForAppending,
         collisionSource: .onAppend(origin: collisionOrigin()))
  }
}
