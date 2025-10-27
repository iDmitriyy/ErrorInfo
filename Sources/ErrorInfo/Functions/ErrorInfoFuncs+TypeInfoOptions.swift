//
//  ErrorInfoFuncs+TypeInfoOptions.swift
//  ErrorInfo
//
//  Created by tmp on 27/10/2025.
//

extension ErrorInfoFuncs {
  internal static func typeDesciptionIfNeeded(forOptional value: (any ErrorInfoValueType)?,
                                              options: TypeInfoOptions) -> String? {
    let type = value.typeOfWrapped()
    return typeDesciptionIfNeeded(for: type, options: options, isOptionalWrapped: true)
  }
  
  internal static func typeDesciptionIfNeeded<T>(for value: T,
                                                 options: TypeInfoOptions) -> String? {
    typeDesciptionIfNeeded(for: T.self, options: options, isOptionalWrapped: false)
  }
  
  private static func typeDesciptionIfNeeded<T>(for type: T.Type,
                                                 options: TypeInfoOptions,
                                                 isOptionalWrapped: Bool) -> String? {
    guard !options.contains([.never, .whenNil]) else { return nil }
    
    switch options {
    case .never:
      return nil
    case .whenNil:
      return if isOptionalWrapped {
        ErrorInfoFuncs.typeDesciption(for: type)
      } else {
        nil
      }
    case .onlyObjects:
      return if type is any AnyObject.Type {
        ErrorInfoFuncs.typeDesciption(for: type)
      } else {
        nil
      }
      
    case .nonBuiltIn:
      return if isOfBuiltinPrimitiveType(value: type) || isOfBuiltinNonPrimitiveType(value: type) {
        nil
      } else {
        ErrorInfoFuncs.typeDesciption(for: type)
      }
      
    case .nonPrimitive:
      return if isOfBuiltinPrimitiveType(value: type) {
        nil
      } else {
        ErrorInfoFuncs.typeDesciption(for: type)
      }
      
    default:
      return ErrorInfoFuncs.typeDesciption(for: type)
    }
  }
  
  private static func typeDesciption<T>(for type: T.Type) -> String {
    let type = type
    return "\(type)"
  }
  
  internal static func isOfBuiltinNonPrimitiveType<T>(value: T.Type) -> Bool {
    // TODO: proper implementation
    if value is Array<Any>.Type {
      true
    } else if value is Set<AnyHashable>.Type {
      true
    } else if value is Dictionary<AnyHashable, Any>.Type {
      true
    } else if value is Array<AnyHashable>.Type {
      true
    } else if value is any RangeExpression.Type { // FIXME: warning
      true
    } else {
      false
    }
  }
  
  internal static func isOfBuiltinPrimitiveType<T>(value: T.Type) -> Bool {
    // Techically String is a collecion, not a primitive. However, specifying String type is redudant and meaningless in most cases.
    if value is any StringProtocol.Type {
      true
    } else if value is any BinaryInteger.Type {
      true
    } else if value is Bool.Type {
      true
    } else if value is any FloatingPoint.Type {
      true
    } else if value is StaticString.Type { // FIXME: warning
      true
    } else {
      false
    }
    
    /*
     Optional
     Character
     UnicodeScalar
     Ranges
     Stride
     CollectionOfOne
     RangeSet
     Result
     Error
     LazyCollections
     Hasher
     ObjectIdentifier
     Pointer
     SIMDVector
     Slices
     */
  }
}

/*
 CustomStringConvertible

 Inherited By:
 BinaryInteger
 CodingKey
 FixedWidthInteger
 LosslessStringConvertible
 SIMD
 SignedInteger
 StringProtocol
 UnsignedInteger

 Conforming Types:
 AnyHashable
 Array
 Conforms when Element conforms to Copyable and Escapable.
 ArraySlice
 Conforms when Element conforms to Copyable and Escapable.
 AtomicLoadOrdering
 AtomicStoreOrdering
 AtomicUpdateOrdering
 Bool
 Character
 ClosedRange
 Conforms when Bound conforms to Comparable.
 ContiguousArray
 Conforms when Element conforms to Copyable and Escapable.
 DefaultStringInterpolation
 Dictionary
 Conforms when Key conforms to Hashable, Value conforms to Copyable, and Value conforms to Escapable.
 Dictionary.Keys
 Conforms when Key conforms to Hashable, Value conforms to Copyable, and Value conforms to Escapable.
 Dictionary.Values
 Conforms when Key conforms to Hashable, Value conforms to Copyable, and Value conforms to Escapable.
 DiscontiguousSlice
 Conforms when Base conforms to Collection.
 DiscontiguousSlice.Index
 Conforms when Base conforms to Collection.
 Double
 Duration
 Float
 Float16
 Float80
 Int
 Int128
 Int16
 Int32
 Int64
 Int8
 KeyValuePairs
 Conforms when Key conforms to Copyable, Key conforms to Escapable, Value conforms to Copyable, and Value conforms to Escapable.
 Mirror
 Range
 Conforms when Bound conforms to Comparable.
 RangeSet
 Conforms when Bound conforms to Comparable.
 RangeSet.Ranges
 Conforms when Bound conforms to Comparable.
 RemoteCallTarget
 SIMD16
 SIMD2
 SIMD3
 SIMD32
 SIMD4
 SIMD64
 SIMD8
 SIMDMask
 Set
 Conforms when Element conforms to Hashable.
 StaticString
 String
 String.Encoding
 String.UTF16View
 String.UTF8View
 String.UnicodeScalarView
 Substring
 TaskLocal
 TaskPriority
 UInt
 UInt128
 UInt16
 UInt32
 UInt64
 UInt8
 Unicode.Scalar
 Unicode.UTF8.ValidationError
 Unicode.UTF8.ValidationError.Kind
 UnownedJob
 WordPair
 */
