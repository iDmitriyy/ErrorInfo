//
//  GenericEqualityTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 19/01/2026.
//

import ErrorInfo
import Testing

struct GenericEqualityTests {
  let count = 200
  private var innerLoopRange: Range<Int> = 0..<20_000
  
  @Test func isEqualAny() async throws {
    let overhead = performMeasuredAction(iterations: count) { _ in
      Void()
    } measure: { _ in
      for index in innerLoopRange {
        blackHole(index)
      }
    }
    
    let (uint1, int1, eq1, neq1) = getValues(5)
    let (uint2, int2, eq2, neq2) = getValues(5)
    
    let (uintAny1, intAny1, eqAny1, neqAny1) = getValuesAny(5)
    let (uintAny2, intAny2, eqAny2, neqAny2) = getValuesAny(5)
    
    let (uintOVal, intOVal, eqOVal, neqOVal) = getOptionalValues(5)
    let (uintONil, intONil, eqONil, neqONil) = getOptionalNil()
        
    let aa = int1 // as ErrorInfo.ValueExistential
    let bb = int2 // as ErrorInfo.ValueExistential
    
    print(ErrorInfoFuncs._isEqualWithUnboxing(nil as Int?, nil as UInt?))
    
    let measured = performMeasuredAction(iterations: count) { _ in
      Void()
    } measure: { _ in
      for _ in innerLoopRange {
//        blackHole(eq1 == eq2)
        blackHole(ErrorInfoFuncs._isEqualWithUnboxingAndStdTypesSpecialization(intAny1, intAny2))
//        blackHole(int1 as any Equatable)
      }
    }
    print((measured.medianDuration - overhead.medianDuration).inMicroseconds)
    // int1 1904
    
    // isEqualAny2(int1, uint2) | 28
    
    // generic a as? any Equatable | ~15 (inlined)
    // int1 as any Equatable | 15
    // A.self == B.self | 0
    // int1 == int2, EQ | 0
  }
  
  @_optimize(none)
  @inline(never)
  func getValuesAny(_ val: Int) -> (Any, Any, Any, Any) {
    (UInt(val), val, EQ(val: "\(val)"), NEQ(val: "\(val)"))
  }
  
  @_optimize(none)
  @inline(never)
  func getValues(_ val: Int) -> (UInt, Int, EQ, NEQ) {
    (UInt(val), val, EQ(val: "\(val)"), NEQ(val: "\(val)"))
  }
  
  @_optimize(none)
  @inline(never)
  func getOptionalValues(_ val: Int) -> (UInt?, Int?, EQ?, NEQ?) {
    getValues(val)
  }
  
  @_optimize(none)
  @inline(never)
  func getOptionalNil() -> (UInt?, Int?, EQ?, NEQ?) {
    (nil, nil, nil, nil)
  }
  
  struct EQ: Equatable {
    let val: String
  }
  
  struct NEQ {
    let val: String
  }
}
