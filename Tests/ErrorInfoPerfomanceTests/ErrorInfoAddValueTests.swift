//
//  ErrorInfoAddValueTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/12/2025.
//

import ErrorInfo
import NonEmpty
import Synchronization
import Testing

struct ErrorInfoAddValueTests {
  private let countBase: Int = 3000
  private let printPrefix = "____addValue:"
  
  private let idKey = "id"
  private let errorCodeKey = "error_code"
  private let indexKey = "index"
    
  /// ## Purpose
  /// The test is a **parameterized micro-benchmark** for `ErrorInfo`’s append logic.
  /// It focuses on measuring the **incremental cost of adding values**, not correctness.
  ///
  /// ## Systematic Coverage
  /// The test exercises:
  /// - Adding **1, 2, or 3 values**
  /// - **Same key vs different keys** to cover collision and non-collision paths
  /// - Multiple **`ValueDuplicatePolicy`** variants to expose policy-dependent costs
  ///
  /// ## Stress on Storage Transitions
  /// The test intentionally forces transitions from:
  /// - empty → single-value storage
  /// - single-value → multi-value storage
  ///
  /// ## Controlled Execution Model
  /// - Uses `@Test(.serialized)` to avoid interference from parallel execution.
  /// - Operates on batches of freshly created `ErrorInfo` instances to avoid state carryover.
  ///
  /// ## Two-Phase Measurement Strategy
  /// The benchmark is split into two phases:
  /// - **Baseline phase (`switchDuration`)** measures loop structure, branching, and switch
  ///   overhead using empty functions.
  /// - **Measured phase (`output`)** performs the actual `mutating funcs` calls.
  ///
  /// The reported time is the **balanced duration** (`output − switchDuration`),
  /// isolating the cost of the append logic.
  ///
  /// ## Why `measurementsCount = countBase / addedValuesCount`
  /// This normalization:
  /// - Keeps the **total number of appended values constant** across test cases.
  /// - Ensures fair comparison between:
  ///   - adding many single values, and
  ///   - adding fewer batches of multiple values.
  /// - Prevents scenarios where “add 3 values” tests would otherwise perform three times
  ///   more work than “add 1 value” tests, which would skew results.
  ///
  /// This ensures both hot paths and rare paths are exercised.
  ///
  /// ## Overall Intent
  /// Produce **stable, apples-to-apples performance numbers** that reflect real storage
  /// behavior rather than test harness overhead.
  @Test(.serialized,
        arguments: [(1, true), (2, true), (2, false), (3, true), (3, false)],
        [ValueDuplicatePolicy.allowEqual, .rejectEqual, .rejectEqualWithSameOrigin])
  @_transparent
  mutating func `add value`(params: (addedValuesCount: Int, addForDifferentKeys: Bool),
                            duplicatePolicy: ValueDuplicatePolicy) {
    let (addedValuesCount, addForDifferentKeys) = params
    
    if #available(macOS 26.0, *) {
      let measurementsCount = countBase / addedValuesCount
      
      let switchDuration = performMeasuredAction(count: measurementsCount, prepare: {
        make1000EmptyInstances()
      }, measure: { infos in
        for _ in infos.indices {
          switch addedValuesCount {
          case 1:
            emptyFunc0()
          case 2:
            if addForDifferentKeys {
              emptyFunc0()
            } else {
              emptyFunc1()
            }
          case 3:
            if addForDifferentKeys {
              emptyFunc0()
            } else {
              emptyFunc1()
            }
          default: Issue.record("Unexpected key-value pairs count \(addedValuesCount)")
          }
        }
      }).duration
      
      let output = performMeasuredAction(count: measurementsCount, prepare: {
        make1000EmptyInstances()
      }, measure: { infos in
        for index in infos.indices {
          switch addedValuesCount {
          case 1:
            infos[index]._addValue_Test(index, duplicatePolicy: duplicatePolicy, forKey: idKey)
            
          case 2:
            let (key1, key2): (String, String)
            if addForDifferentKeys {
              (key1, key2) = (idKey, errorCodeKey)
            } else {
              (key1, key2) = (errorCodeKey, errorCodeKey)
            }
            infos[index]._addValue_Test(index, duplicatePolicy: duplicatePolicy, forKey: key1)
            infos[index]._addValue_Test(index, duplicatePolicy: duplicatePolicy, forKey: key2)
            
          case 3:
            let (key1, key2, key3): (String, String, String)
            if addForDifferentKeys {
              (key1, key2, key3) = (idKey, errorCodeKey, indexKey)
            } else {
              (key1, key2, key3) = (errorCodeKey, errorCodeKey, errorCodeKey)
            }
            infos[index]._addValue_Test(index, duplicatePolicy: duplicatePolicy, forKey: key1)
            infos[index]._addValue_Test(index, duplicatePolicy: duplicatePolicy, forKey: key2)
            infos[index]._addValue_Test(index, duplicatePolicy: duplicatePolicy, forKey: key3)
            
          default: Issue.record("Unexpected key-value pairs count \(addedValuesCount)")
          }
        }
      })
      
      /* new imp (optimized NonEmptyOrderedIndexSet to multi indices transition initializer)
       532.0    add 1 value for different keys, policy: allowEqual
       578.5    add 1 value for different keys, policy: rejectEqual
       575.1    add 1 value for different keys, policy: rejectEqualWithSameOrigin
       
       622.9    add 2 values for different keys, policy: allowEqual
       667.5    add 2 values for different keys, policy: rejectEqual
       662.4    add 2 values for different keys, policy: rejectEqualWithSameOrigin
       
       871.5    add 2 values for same key, policy: allowEqual
       533.6    add 2 values for same key, policy: rejectEqual
       538.0    add 2 values for same key, policy: rejectEqualWithSameOrigin
       
       651.6    add 3 values for different keys, policy: allowEqual
       693.3    add 3 values for different keys, policy: rejectEqual
       691.7    add 3 values for different keys, policy: rejectEqualWithSameOrigin
       
       865.0    add 3 values for same key, policy: allowEqual
       504.8    add 3 values for same key, policy: rejectEqual
       511.6    add 3 values for same key, policy: rejectEqualWithSameOrigin
       */
      
      /* new imp (optimized copy to multi storage algorithm)
       538.8    add 1 value for different keys, policy: allowEqual
       588.4    add 1 value for different keys, policy: rejectEqual
       588.1    add 1 value for different keys, policy: rejectEqualWithSameOrigin
       
       631.8    add 2 values for different keys, policy: allowEqual
       676.0    add 2 values for different keys, policy: rejectEqual
       674.3    add 2 values for different keys, policy: rejectEqualWithSameOrigin
       
       2106.9   add 2 values for same key, policy: allowEqual
       535.4    add 2 values for same key, policy: rejectEqual
       541.4    add 2 values for same key, policy: rejectEqualWithSameOrigin
       
       665.6    add 3 values for different keys, policy: allowEqual
       705.7    add 3 values for different keys, policy: rejectEqual
       708.0    add 3 values for different keys, policy: rejectEqualWithSameOrigin
       
       1690.8   add 3 values for same key, policy: allowEqual
       510.9    add 3 values for same key, policy: rejectEqual
       517.3    add 3 values for same key, policy: rejectEqualWithSameOrigin
       */
      
      /* new imp
       532.9    add 1 value for different keys, policy: allowEqual
       575.0    add 1 value for different keys, policy: rejectEqual
       575.9    add 1 value for different keys, policy: rejectEqualWithSameOrigin
       
       624.7    add 2 values for different keys, policy: allowEqual
       669.5    add 2 values for different keys, policy: rejectEqual
       670.0    add 2 values for different keys, policy: rejectEqualWithSameOrigin
       
       2170.3   add 2 values for same key, policy: allowEqual
       527.8    add 2 values for same key, policy: rejectEqual
       534.1    add 2 values for same key, policy: rejectEqualWithSameOrigin
       
       656.7    add 3 values for different keys, policy: allowEqual
       697.8    add 3 values for different keys, policy: rejectEqual
       700.3    add 3 values for different keys, policy: rejectEqualWithSameOrigin
       
       1722.2   add 3 values for same key, policy: allowEqual
       502.2    add 3 values for same key, policy: rejectEqual
       511.0    add 3 values for same key, policy: rejectEqualWithSameOrigin
       */
      
      /* new imp (after restart)
       538.8    add 1 value for different keys, policy: allowEqual
       576.2    add 1 value for different keys, policy: rejectEqual
       579.7    add 1 value for different keys, policy: rejectEqualWithSameOrigin
       
       632.0    add 2 values for different keys, policy: allowEqual
       678.0    add 2 values for different keys, policy: rejectEqual
       680.3    add 2 values for different keys, policy: rejectEqualWithSameOrigin
       
       2167.4   add 2 values for same key, policy: allowEqual
       538.7    add 2 values for same key, policy: rejectEqual
       544.4    add 2 values for same key, policy: rejectEqualWithSameOrigin
       
       661.5    add 3 values for different keys, policy: allowEqual
       708.0    add 3 values for different keys, policy: rejectEqual
       702.6    add 3 values for different keys, policy: rejectEqualWithSameOrigin
       
       1738.0   add 3 values for same key, policy: allowEqual
       506.1    add 3 values for same key, policy: rejectEqual
       512.5    add 3 values for same key, policy: rejectEqualWithSameOrigin
       */
      
      /* new imp
       518.0    add 1 value for different keys, policy: allowEqual
       569.7    add 1 value for different keys, policy: rejectEqual
       572.0    add 1 value for different keys, policy: rejectEqualWithSameOrigin
       
       613.5    add 2 values for different keys, policy: allowEqual
       656.7    add 2 values for different keys, policy: rejectEqual
       656.3    add 2 values for different keys, policy: rejectEqualWithSameOrigin
       
       2133.8   add 2 values for same key, policy: allowEqual
       519.7    add 2 values for same key, policy: rejectEqual
       527.4    add 2 values for same key, policy: rejectEqualWithSameOrigin
       
       647.4    add 3 values for different keys, policy: allowEqual
       691.2    add 3 values for different keys, policy: rejectEqual
       683.1    add 3 values for different keys, policy: rejectEqualWithSameOrigin
       
       1700.4   add 3 values for same key, policy: allowEqual
       496.4    add 3 values for same key, policy: rejectEqual
       502.0    add 3 values for same key, policy: rejectEqualWithSameOrigin
       */
      
      /* old imp
       527.0    add 1 value for different keys, policy: allowEqual
       805.3    add 1 value for different keys, policy: rejectEqual
       807.2    add 1 value for different keys, policy: rejectEqualWithSameOrigin
       
       608.5    add 2 values for different keys, policy: allowEqual
       891.5    add 2 values for different keys, policy: rejectEqual
       896.8    add 2 values for different keys, policy: rejectEqualWithSameOrigin
       
       2128.7   add 2 values for same key, policy: allowEqual
       911.8    add 2 values for same key, policy: rejectEqual
       916.5    add 2 values for same key, policy: rejectEqualWithSameOrigin
       
       637.6    add 3 values for different keys, policy: allowEqual
       936.9    add 3 values for different keys, policy: rejectEqual
       938.9    add 3 values for different keys, policy: rejectEqualWithSameOrigin
       
       1698.9   add 3 values for same key, policy: allowEqual
       914.9    add 3 values for same key, policy: rejectEqual
       928.1    add 3 values for same key, policy: rejectEqualWithSameOrigin
       */
      
      // if addedValuesCount == 1 {
      //   print(printPrefix, "1000 empty total ", output.preparationsDuration.asString(fractionDigits: 5))
      // }
      
      let addedValues = "add \(addedValuesCount) " + (addedValuesCount == 1 ? "value" : "values")
      let whichKeys = "\(addForDifferentKeys ? "different keys" : "same key")"
      let policy = ", policy: \(duplicatePolicy)"
      
      let balancedDuration = (output.duration - switchDuration).asString(fractionDigits: 1)
      
      print(printPrefix, balancedDuration, addedValues + " for " + whichKeys + policy, separator: "\t\t")
    }
  }
  
  @available(macOS 26.0, *)
  @_transparent
  internal func make1000EmptyInstances() -> InlineArray<1000, ErrorInfo> {
    InlineArray<1000, ErrorInfo>({ _ in ErrorInfo() })
  }
  
  
}
