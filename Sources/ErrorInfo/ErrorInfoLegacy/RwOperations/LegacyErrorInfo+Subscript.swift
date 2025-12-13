//
//  LegacyErrorInfo+Subscript.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 12/12/2025.
//

extension LegacyErrorInfo {
  @_disfavoredOverload
  public subscript(_: StringLiteralKey) -> InternalRestrictionToken? {
    @available(*, deprecated, message: "To remove value use removeValue(forKey:) function")
    set {}
    
    @available(*, unavailable, message: "This is a stub subscript. To remove value use removeValue(forKey:) function")
    get { nil }
  }
  
  // MARK: - Read access Subscript
    
  public subscript<T>(_ literalKey: StringLiteralKey) -> T? {
    get {
      nil
    }
    set {
      
    }
  }
}
