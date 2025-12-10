//
//  String+Concat.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 10/12/2025.
//

extension String {
  // TODO: - write perfomance tests to measure that it is faster than usin + operator severaal times ("a" + "b" + "c")
  // check is it faster than using String instead of `some StringProtocol` instances, is for StringProtocol
  // append(contentsOf:) is used, which can be slower.
  // compare to `.joined()`
  // https://github.com/swiftlang/swift/blob/3dcd9bb011ce21376ca1a8e4656fdc4c11cd9f13/stdlib/public/core/String.swift#L908
  // internal static func _concat<each D>(_ strings: repeat each D) -> Self where repeat each D: StringProtocol {
  //   var capacity: Int = 0
  //   for string in repeat each strings {
  //     capacity += string.utf8.count
  //   }
  //
  //   var result = String(minimumCapacity: capacity)
  //
  //   for string in repeat each strings {
  //     result.append(contentsOf: string)
  //   }
  //
  //   return result
  // }
  
  internal static func concat(_ a: consuming String,
                              _ b: consuming String) -> Self {
    let capacity = a.utf8.count + b.utf8.count
    
    var result = String(minimumCapacity: capacity)
    
    result.append(a)
    result.append(b)
    
    return result
  }
  
  internal static func concat(_ a: consuming String,
                              _ b: consuming String,
                              _ c: consuming String) -> Self {
    let capacity = a.utf8.count + b.utf8.count + c.utf8.count
    
    var result = String(minimumCapacity: capacity)
    
    result.append(a)
    result.append(b)
    result.append(c)
    
    return result
  }
  
  internal static func concat(_ a: consuming String,
                              _ b: consuming String,
                              _ c: consuming String,
                              _ d: consuming String) -> Self {
    let capacity = a.utf8.count + b.utf8.count + c.utf8.count + d.utf8.count
    
    var result = String(minimumCapacity: capacity)
    
    result.append(a)
    result.append(b)
    result.append(c)
    result.append(d)
    
    return result
  }
  
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
