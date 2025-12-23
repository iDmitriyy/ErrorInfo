//
//  StringLiteralKeyDefault.swift
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

// Improvement: use compile-time values instead of static.
// Currently all these strings consume ~168Kb of binary size. replacing static lets by compile-time values might
// reduce memory consumption
// Amount of memory needed can also be dependant on:
// 1. store raw StaticString literals
// 2. store `static let` or `const let`
// This can increase the aamount of memory by a factor of 2. Need to be inspected.

// MARK: - Common key prefixes / suffixed

extension StringLiteralKey {
  /// e.g.: .invalid + .value, .invalid + .index
  public static let invalid: StringLiteralKey = "invalid"
  /// e.g.: .unchecked + .value, .unchecked + .index
  public static let unchecked: StringLiteralKey = "unchecked"
  /// e.g.: .unexpected + .value, .unexpected + .index
  public static let unexpected: StringLiteralKey = "unexpected"
  
  /// e.g.: .debug + .timestamp
  public static let debug: StringLiteralKey = "debug"
  /// e.g.: .raw + .status
  public static let raw: StringLiteralKey = "raw"
  
  /// e.g.: .source + .state
  public static let source: StringLiteralKey = "source"
  /// e.g.: .target + .state
  public static let target: StringLiteralKey = "target"
  
  /// e.g.: .request + .duration
  public static let request: StringLiteralKey = "request"
  /// e.g.: .response + .duration
  public static let response: StringLiteralKey = "response"
  
  /// e.g.: .decoding + .duration
  public static let decoding: StringLiteralKey = "decoding"
  /// e.g.: .encoding + .duration
  public static let encoding: StringLiteralKey = "encoding"
  
  /// e.g.: .response + .payload
  public static let payload: StringLiteralKey = "payload"
  
  /// e.g.: .debug + .info
  public static let info: StringLiteralKey = "info"
  
  /// e.g.: .operation + .name
  public static let operation: StringLiteralKey = "operation"
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension StringLiteralKey {
  // MARK: - Commonly used keys
  
  public static let timestamp: StringLiteralKey = "timestamp"
  public static let date: StringLiteralKey = "date"
  public static let duration: StringLiteralKey = "duration"
  public static let durationInSeconds: StringLiteralKey = "duration_in_seconds"
  
  public static let status: StringLiteralKey = "status"
  public static let statusID: StringLiteralKey = "status_id"
  public static let statusCode: StringLiteralKey = "status_code"
  
  public static let state: StringLiteralKey = "state"
  
  public static let value: StringLiteralKey = "value"
  public static let rawValue: StringLiteralKey = "raw_value"
  public static let intValue: StringLiteralKey = "int_value"
  public static let stringValue: StringLiteralKey = "string_value"
  public static let instance: StringLiteralKey = "instance"
  public static let object: StringLiteralKey = "object"
  
  public static let type: StringLiteralKey = "type"
  public static let valueType: StringLiteralKey = "value_type"
  public static let objectType: StringLiteralKey = "object_type"
  public static let instanceType: StringLiteralKey = "instance_type"
  
  public static let index: StringLiteralKey = "index"
  public static let indices: StringLiteralKey = "indices"
  
  public static let url: StringLiteralKey = "url"
  public static let query: StringLiteralKey = "query"
  public static let interpolation: StringLiteralKey = "interpolation"
  
  public static let message: StringLiteralKey = "message"
  public static let debugMessage: StringLiteralKey = "debug_message"
  public static let localizedMessage: StringLiteralKey = "localized_message"
  
  public static let description: StringLiteralKey = "description"
  public static let debugDescription: StringLiteralKey = "debug_description"
  
  public static let name: StringLiteralKey = "name"
  public static let task: StringLiteralKey = "task"
  public static let resource: StringLiteralKey = "resource"
  
  public static let donator: StringLiteralKey = "donator"
  public static let recipient: StringLiteralKey = "recipient"
  
  public static let file: StringLiteralKey = "file"
  public static let line: StringLiteralKey = "line"
  public static let fileLine: StringLiteralKey = "file_line"
  public static let function: StringLiteralKey = "function"
  
  public static let dataString: StringLiteralKey = "data_string"
  public static let base64String: StringLiteralKey = "base64_string"
  public static let bytesCount: StringLiteralKey = "bytes_count"
  public static let dataBytesCount: StringLiteralKey = "data_bytes_count"
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension StringLiteralKey {
  // MARK: - Basic Information
  
  public static let id: StringLiteralKey = "id"
  public static let uuid: StringLiteralKey = "uuid"
  public static let instanceID: StringLiteralKey = "instance_id"
  public static let objectID: StringLiteralKey = "object_id"
  public static let taskID: StringLiteralKey = "task_id"
  public static let sessionID: StringLiteralKey = "session_id"
  public static let operationID: StringLiteralKey = "operation_id"
  public static let transactionID: StringLiteralKey = "transaction_id"
  
  public static let host: StringLiteralKey = "host"
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension StringLiteralKey {
  // MARK: - Error Context
  
  public static let errorCode: StringLiteralKey = "error_code"
  public static let errorDomain: StringLiteralKey = "error_domain"
  public static let errorDescription: StringLiteralKey = "error_description"
  public static let errorDebugDescription: StringLiteralKey = "error_debug_description"
  public static let errorMessage: StringLiteralKey = "error_message"
  public static let errorLocalizedMessage: StringLiteralKey = "error_localized_message"
  
  /// e.g., network, database, validation
  public static let errorType: StringLiteralKey = "error_type"
  
  public static let failureReason: StringLiteralKey = "failure_reason"
  public static let errorSource: StringLiteralKey = "error_source"
  
  public static let severity: StringLiteralKey = "severity"
  
  public static let underlyingError: StringLiteralKey = "underlying_error"
  public static let exception: StringLiteralKey = "exception"
  
  public static let retryAttemptsLimit: StringLiteralKey = "retry_attempts_limit"
  public static let retryCount: StringLiteralKey = "retry_count"
  public static let retryDelay: StringLiteralKey = "retry_delay"
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension StringLiteralKey {
  // MARK: - Network & Connectivity Information
  
  public static let httpStatusCode: StringLiteralKey = "http_status_code"
  
  public static let httpMethod: StringLiteralKey = "http_method"
  public static let requestMethod: StringLiteralKey = "request_method"
  public static let requestURL: StringLiteralKey = "request_url"
  public static let requestBody: StringLiteralKey = "request_body"
  
  public static let responseBody: StringLiteralKey = "response_body"
  
  public static let apiEndpoint: StringLiteralKey = "api_endpoint"
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension StringLiteralKey {
  // MARK: - App Usage Data
  
  public static let hasPermission: StringLiteralKey = "has_permission"
  public static let permissionStatus: StringLiteralKey = "permission_status"
  
  public static let isLoggedIn: StringLiteralKey = "is_logged_in"
  public static let authenticationStatus: StringLiteralKey = "authentication_status"
  public static let authorizationStatus: StringLiteralKey = "authorization_status"
}

// TBD: https://forums.swift.org/t/static-let-vs-computed-properties-and-binary-size/83706/6
// `static let` vs computed properties, and binary size
