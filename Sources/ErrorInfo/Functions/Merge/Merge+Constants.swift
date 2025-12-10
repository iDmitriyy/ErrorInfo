//
//  ErrorInfo+Merge.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 26/07/2025.
//

extension Merge.Constants {
  /// "$"
  internal static let randomSuffixBeginningForSubcriptAsciiCode: UInt8 = 36
  /// "$"
  internal static let randomSuffixBeginningForSubcriptScalar = UnicodeScalar(randomSuffixBeginningForSubcriptAsciiCode)
  
  /// "#"
  internal static let randomSuffixBeginningForMergeAsciiCode: UInt8 = 35
  /// "#"
  internal static let randomSuffixBeginningForMergeScalar = UnicodeScalar(randomSuffixBeginningForMergeAsciiCode)
}
