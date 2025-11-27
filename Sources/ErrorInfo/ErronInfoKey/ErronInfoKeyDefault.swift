//
//  ErronInfoKeyDefault.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 26/07/2025.
//

/*
 The following categories of keys are intentionally not added:
 - memoryUsage, cpuUsage, freeDiskSpace, frame_rate, isDebuggerAttached ...
 - deviceOrientation, screenBrightness, hasCamera ...
 - locale, language, timezone ...
 - platform, deviceType, isSimulator, cpuArchitecture ...
 
 Such params are:
 - Typically not added to common errors created by programmers of a team. They are narrowly used in specific contexts.
 - Provided out of the box by common services like Sentry, or Firebase.
 
 Default key literals are added for most often used params.
 Of someone need project or domain-specific default keys, they are free to add their own in an extension to `ErronInfoLiteralKey`.
 */

// By default names are given with snake_case, which can ba transformed to camelCase, kebab-case or PascalCase
// formats when logging.
// TODO: - inspect Swift codebases for styles
// TODO: - use compile-time values instead of static.
// Currently all these strings consume ~168Kb of binary size. replacing static lets by compile-time values might
// reduce memory consumption

extension ErronInfoLiteralKey {
  // MARK: Common key prefixes
  
  /// e.g.: .invalid + .value, .invalid + .index
  public static let invalid: ErronInfoLiteralKey = "invalid"
  /// e.g.: .unchecked + .value, .unchecked + .index
  public static let unchecked: ErronInfoLiteralKey = "unchecked"
  /// e.g.: .unexpected + .value, .unexpected + .index
  public static let unexpected: ErronInfoLiteralKey = "unexpected"
  
  /// e.g.: .debug + .timestamp
  public static let debug: ErronInfoLiteralKey = "debug"
  /// e.g.: .raw + .status
  public static let raw: ErronInfoLiteralKey = "raw"
  
  /// e.g.: .source + .state
  public static let source: ErronInfoLiteralKey = "source"
  /// e.g.: .target + .state
  public static let target: ErronInfoLiteralKey = "target"
  
  /// e.g.: .request + .duration
  public static let request: ErronInfoLiteralKey = "request"
  /// e.g.: .response + .duration
  public static let response: ErronInfoLiteralKey = "response"
  
  /// e.g.: .decoding + .duration
  public static let decoding: ErronInfoLiteralKey = "decoding"
  /// e.g.: .encoding + .duration
  public static let encoding: ErronInfoLiteralKey = "encoding"
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension ErronInfoLiteralKey {
  // MARK: - Commonly used keys
  
  public static let date: ErronInfoLiteralKey = "date"
  public static let duration: ErronInfoLiteralKey = "duration"
  public static let timestamp: ErronInfoLiteralKey = "timestamp"
  
  public static let status: ErronInfoLiteralKey = "status"
  public static let statusID: ErronInfoLiteralKey = "status_id"
  public static let statusCode: ErronInfoLiteralKey = "status_code"
  
  public static let state: ErronInfoLiteralKey = "state"
  
  public static let value: ErronInfoLiteralKey = "value"
  public static let rawValue: ErronInfoLiteralKey = "raw_value"
  public static let intValue: ErronInfoLiteralKey = "int_value"
  public static let stringValue: ErronInfoLiteralKey = "string_value"
  public static let instance: ErronInfoLiteralKey = "instance"
  public static let object: ErronInfoLiteralKey = "object"
  
  public static let type: ErronInfoLiteralKey = "type"
  public static let valueType: ErronInfoLiteralKey = "value_type"
  public static let objectType: ErronInfoLiteralKey = "object_type"
  public static let instanceType: ErronInfoLiteralKey = "instance_type"
  
  public static let index: ErronInfoLiteralKey = "index"
  public static let indices: ErronInfoLiteralKey = "indices"
  
  public static let url: ErronInfoLiteralKey = "url"
  public static let query: ErronInfoLiteralKey = "query"
  public static let interpolation: ErronInfoLiteralKey = "interpolation"
  
  public static let message: ErronInfoLiteralKey = "message"
  public static let debugMessage: ErronInfoLiteralKey = "debug_message"
  public static let localizedMessage: ErronInfoLiteralKey = "localized_message"
  
  public static let description: ErronInfoLiteralKey = "description"
  public static let debugDescription: ErronInfoLiteralKey = "debug_description"
  
  public static let name: ErronInfoLiteralKey = "name"
  public static let resource: ErronInfoLiteralKey = "resource"
  
  public static let donator: ErronInfoLiteralKey = "donator"
  public static let recipient: ErronInfoLiteralKey = "recipient"
  
  public static let file: ErronInfoLiteralKey = "file"
  public static let line: ErronInfoLiteralKey = "line"
  public static let fileLine: ErronInfoLiteralKey = "file_line"
  public static let function: ErronInfoLiteralKey = "function"
  
  public static let dataString: ErronInfoLiteralKey = "data_string"
  public static let base64String: ErronInfoLiteralKey = "base64_string"
  public static let bytesCount: ErronInfoLiteralKey = "bytes_count"
  public static let dataBytesCount: ErronInfoLiteralKey = "data_bytes_count"
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension ErronInfoLiteralKey {
  // MARK: - Basic Information
  
  public static let id: ErronInfoLiteralKey = "id"
  public static let uuid: ErronInfoLiteralKey = "uuid"
  public static let instanceID: ErronInfoLiteralKey = "instance_id"
  public static let objectID: ErronInfoLiteralKey = "object_id"
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension ErronInfoLiteralKey {
  // MARK: - Error Context
  
  public static let errorCode: ErronInfoLiteralKey = "error_code"
  public static let errorDomain: ErronInfoLiteralKey = "error_domain"
  public static let errorDescription: ErronInfoLiteralKey = "error_description"
  public static let errorDebugDescription: ErronInfoLiteralKey = "error_debug_description"
  public static let errorMessage: ErronInfoLiteralKey = "error_message"
  public static let errorLocalizedMessage: ErronInfoLiteralKey = "error_localized_message"
  
  /// e.g., network, database, validation
  public static let errorType: ErronInfoLiteralKey = "error_type"
  
  public static let failureReason: ErronInfoLiteralKey = "failure_reason"
  public static let errorSource: ErronInfoLiteralKey = "error_source"
  
  public static let severity: ErronInfoLiteralKey = "severity"
  
  public static let underlyingError: ErronInfoLiteralKey = "underlying_error"
  public static let exception: ErronInfoLiteralKey = "exception"
  
  public static let retryAttemptsLimit: ErronInfoLiteralKey = "retry_attempts_limit"
  public static let retryCount: ErronInfoLiteralKey = "retry_count"
  public static let retryDelay: ErronInfoLiteralKey = "retry_delay"
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension ErronInfoLiteralKey {
  // MARK: - Network & Connectivity Information
  
  public static let httpStatusCode: ErronInfoLiteralKey = "http_status_code"
  
  public static let requestMethod: ErronInfoLiteralKey = "request_method"
  public static let requestURL: ErronInfoLiteralKey = "request_url"
  public static let requestBody: ErronInfoLiteralKey = "request_body"
  
  public static let responseBody: ErronInfoLiteralKey = "response_body"
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension ErronInfoLiteralKey {
  // MARK: - App Usage Data
  
  public static let hasPermission: ErronInfoLiteralKey = "has_permission"
  public static let permissionStatus: ErronInfoLiteralKey = "permission_status"
  
  public static let isLoggedIn: ErronInfoLiteralKey = "is_logged_in"
  public static let authenticationStatus: ErronInfoLiteralKey = "authentication_status"
  public static let authorizationStatus: ErronInfoLiteralKey = "authorization_status"
}
