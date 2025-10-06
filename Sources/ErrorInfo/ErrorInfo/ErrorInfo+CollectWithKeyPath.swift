//
//  ErrorInfo+CollectWithKeyPath.swift
//  ErrorInfo
//
//  Created by tmp on 06/10/2025.
//

// MARK: - Collect values from KeyPath

extension ErrorInfo {
  // public static func fromKeys<T, each V: ErrorInfo.ValueType>(of instance: T,
  @inlinable
  public static func collect<R, each V: ErrorInfo.ValueType>(from instance: R,
                                                             addTypePrefix: Bool,
                                                             keys key: repeat KeyPath<R, each V>) -> Self {
    func collectEach(_ keyPath: KeyPath<R, some ErrorInfo.ValueType>, root: R, to info: inout Self) {
      var keyPathString = ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath)
      if addTypePrefix {
        keyPathString = "\(type(of: root))." + keyPathString
      }
      // TODO: if keyPathString can not be formed correctly then macro can be tried
      info[keyPathString] = root[keyPath: keyPath]
    }
    // ⚠️ @iDmitriyy
    // TODO: - add tests
    // TODO: check CoW for `inout Self`
    var info = Self()
    
    repeat collectEach(each key, root: instance, to: &info)
    
    return info
  }
}
