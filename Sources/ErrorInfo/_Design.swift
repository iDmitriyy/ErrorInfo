//
//  _Design.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 01/08/2025.
//

/*
 Usage / applying:
 (AnyBaseError -> AnyErrorChainable(Adapter))
 - Concrete error types can either use errorInfo with either `keyAugmentation` or `multipleValues` strategy.
 ?? Which strategy is commonly preferred.
 - When errors chain summary info is merged, if collision happens then it is good to understand from each error each value
 was. Donator index can be used if two errors have the same domain, code, identity (e.g. file shortand)
 In very rare cases when 2 errors:
    - have the same domain ("ME" – MappingError)
    - have the same code (7)
    - created in different files and short variants of these file names are equal ("MVC" – MainViewController | MapViewController)
    - created at the same line in those different files (40)
  a random donator index is added.
 Index is increasing from right to left, where most deep error is always at index 0. New codes alwas appear at the left side and
 will be at endIndex + 1
 Example: during collision resolution of 2 diferent values the following keys were created:
 "time_ME7@MVC_40_idx0"
 "time_ME7@MVC_40_idx2"
 ?? may be line can be omited and idx shpuld be used. If error identity(writeProvenance) is equal, mostly often it is the same
 file. So line number seems to look like a noise. This looks better:
 "time_ME7@MVC^idx0" || "time_ME7@MVC[i0]" || "time_ME7@MVC(0)"
 "time_ME7@MVC^idx1" || "time_ME7@MVC[i2]" || "time_ME7@MVC(2)"
 
 Value's writeProvenance should be added after collisions resolution between error. If error instance have 2 values for a key, then errorDomain+code suffix will also add a random suffix, and then writeProvenance from multivalue-type is ni useless.
 Firstly it is needed to add error writeProvenance when merging between errors, and then check if there are colssions inside error bounds. If yes then multiValue writeProvenance is added, and only after that random suffix is added.
 
 MultiValue is also preferreble vs `in-place aaugmentation` as it preserves `values(forKey:)` and `hasValues(forKey:)`.
 If key augmented when added, then listed above functions will return only first value.
 
 Make SUI app (for MacOS firstly, but crosspplatform) with error-type selectors
 [ErrType1]  [ErrType2] + ... up to 5
 add: k-val  add: k-val
 
   info1       info1
    [:]         [:]
        Summary:
          [:]
 */
