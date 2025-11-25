//
//  IsEqualAnyEqatableTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

@testable import ErrorInfo
import Foundation
import Testing

struct IsEqualAnyEqatableTests {
  @Test func basic() throws {
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Int(1), b: Int(1)) == true)
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Int(1), b: UInt(1)) == false)
    
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Int(1),
                                              b: Optional(Int(1))) == true)
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Optional(Int(1)),
                                              b: Int(1)) == true)
    
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Int(1),
                                              b: Optional(Optional(Int(1)))) == true)
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Optional(Optional(Int(1))),
                                              b: Int(1)) == true)
    
    
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Int(1),
                                              b: Optional<Int>.none) == false)
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Optional<Int>.none,
                                              b: Int(1)) == false)
    
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Int(1),
                                              b: Optional<Optional<Int>>.none) == false)
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Optional<Optional<Int>>.none,
                                              b: Int(1)) == false)
    
    
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Optional<Int>.none, b: Optional<Int>.none) == true)
    
    // FIXME: nil instances can be casted to each Optional<T>, no matter what T is.
    // However, for ErrorInfo purposes Optional<Int>.none & Optional<String>.none should not be equal.
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Optional<Int>.none, b: Optional<UInt>.none) == false)
    
    // For nested oprionals, like Optional<Optional<Int>>, no matter how many nesting levels introduces, we need to make a choices:
    // 1. treat Optional<Optional<Int>> as if it flattened to Optional<Int>, so nil instances are equal
    // 2. treat optionals with different nesting levele not equal
    // Optional instances  that are kept in ErrorInfo are not needed for typilcal usage – almost always we are interested in
    // values, not nil instances.
    // nil instances are useful for debugging and logging, to inspect is there collisions happen.
    // From this perspective nil instances of different types, and different optional nesting levels particulary, are different
    // things.
    // From the other side, it is felt naturaly that nil instances are compared the same way optional non-nil values – not matter
    // how many nsting levels there are, they are equal if their underlying wrapped values are equal. From this point of view
    // 2 nil instances are equal if the Wrapped Type is equal. Mentally it is the same as flattening to a single level of
    // optionality.
    
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Optional<Int>.none,
                                              b: Optional<Optional<Int>>.none) == true)
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Optional<Optional<Int>>.none,
                                              b: Optional<Int>.none) == false)
  }
}
