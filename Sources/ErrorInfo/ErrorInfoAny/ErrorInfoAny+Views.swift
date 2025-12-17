//
//  ErrorInfoAny+Views.swift
//  ErrorInfo
//
//  Created by tmp on 17/12/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

extension ErrorInfoAny {
  public var keys: some _UniqueCollection & Collection<String> { _storage.keys }
  
  public var allKeys: some Collection<String> { _storage.allKeys }
}
