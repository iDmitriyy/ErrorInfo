//
//  ErrorInfoAny+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

extension ErrorInfoAny {
  public var keys: some _UniqueCollection & Collection<String> { _storage.keys }
  
  public var allKeys: some Collection<String> { _storage.allKeys }
}
