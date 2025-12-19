//
//  Measure.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

public import Foundation

@inlinable
@inline(__always)
@discardableResult
internal func performMeasuredAction<T>(count: Int, _ actions: () -> T) -> (results: [T], duration: Double) {
  let clock = ContinuousClock()
    
  var results: [T] = []
  
//  var totalDuration = UInt64(0) // Duration.zero
//  for _ in 1...count{
//    let initialTime = DispatchTime.now().uptimeNanoseconds // clock.now
//    let result = actions()
//    let endTime = DispatchTime.now().uptimeNanoseconds // clock.now
//    let difference = endTime - initialTime
//    totalDuration += difference
//    results.append(result)
//  }
//  let ms = Double(totalDuration) / 1_000_000 // totalDuration.inMilliseconds
  
  var totalDuration = Duration.zero
  for _ in 1...count {
    let initialTime = clock.now
    let result = actions()
    let endTime = clock.now
    let difference = endTime - initialTime
    totalDuration += difference
    results.append(result)
  }
  
  let ms = totalDuration.inMilliseconds
  
  return (results, ms)
}

@inlinable
@inline(__always)
@discardableResult
internal func performMeasuredAction<T>(_ actions: () -> T) -> (result: T, duration: Double) {
  let clock = ContinuousClock()
  
  let initialTime = clock.now
  let result = actions()
  let endTime = clock.now
  let difference = endTime - initialTime
  
  return (result, difference.inMilliseconds)
}

extension Duration {
  @usableFromInline internal var inMilliseconds: Double {
    let (seconds, attoseconds) = components
    return Double(seconds) * 1000 + Double(attoseconds) * 1e-15
  }
}

struct VariadicTuple<each T> {
  let elements: (repeat each T)
  
  init(_ elements: repeat each T) {
    self.elements = (repeat each elements)
  }
}

@inline(never) @_optimize(none)
public func blackHole<T>(_ thing: T) {
  _ = thing
}

extension Double {
  public func asString(fractionDigits: UInt8) -> String {
    String(format: "%.\(fractionDigits)f", self)
  }
}

@inlinable @inline(__always)
internal func mutate<T: ~Copyable, E>(value: consuming T, mutation: (inout T) throws(E) -> Void) throws(E) -> T {
  try mutation(&value)
  return value
}
