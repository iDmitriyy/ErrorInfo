//
//  String+Concat.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 10/12/2025.
//

extension String {
  /// Concatenates multiple `String` values into a single `String`.
  /// Optimized for performance when concatenating a small fixed number of strings.
  ///
  /// ## Performance:
  /// - For 5 or more elements, this method is approximately `1.2x` faster than using `Array<String>.joined()` or the `+` operator.
  /// - For fewer elements, using the `+` operator may offer better performance due to its simplicity.
  @inlinable @inline(__always)
  internal static func concat(_ a: consuming String,
                              _ b: consuming String,
                              _ c: consuming String,
                              _ d: consuming String,
                              _ e: consuming String) -> Self {
    let capacity = a.utf8.count + b.utf8.count + c.utf8.count + d.utf8.count + e.utf8.count
    
    var result = String(minimumCapacity: capacity)
    
    result.append(a)
    result.append(b)
    result.append(c)
    result.append(d)
    result.append(e)
    
    return result
  }
  
  /// Concatenates multiple `String` values into a single `String`.
  /// Optimized for performance when concatenating a small fixed number of strings.
  ///
  /// ## Performance:
  /// - For 5 or more elements, this method is approximately `1.2x` faster than using `Array<String>.joined()` or the `+` operator.
  /// - For fewer elements, using the `+` operator may offer better performance due to its simplicity.
  @inlinable @inline(__always)
  internal static func concat(_ a: consuming String,
                              _ b: consuming String,
                              _ c: consuming String,
                              _ d: consuming String,
                              _ e: consuming String,
                              _ f: consuming String) -> Self {
    let capacity = a.utf8.count + b.utf8.count + c.utf8.count + d.utf8.count + e.utf8.count + f.utf8.count
    
    var result = String(minimumCapacity: capacity)
        
    result.append(a)
    result.append(b)
    result.append(c)
    result.append(d)
    result.append(e)
    result.append(f)
    
    return result
  }
}
