//
//  String+Concat.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 10/12/2025.
//

extension String {
  /*
   For 5, 6 and more elements String.concat is ~1.2x faster than Array<String>.joined() or + operator
   For less elements + operator seems to be more perfomant.
   */
  
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
