//
//  ErronInfoKeyDefault.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 26/07/2025.
//

extension ErronInfoLiteralKey {
  // By default names are given with snake_case, which can ba transformed to camelCase, kebab-case or PascalCase
  // formats when logging.
  // TODO: - inspect Swift codebases for styles
  // TODO: - use compile-time values instead of static
  
  public static let id = ErronInfoLiteralKey(uncheckedString: "id")
  public static let instanceID = ErronInfoLiteralKey(uncheckedString: "instance_id")
  public static let objectID = ErronInfoLiteralKey(uncheckedString: "object_id")
  
  public static let status = ErronInfoLiteralKey(uncheckedString: "status")
  public static let statusID = ErronInfoLiteralKey(uncheckedString: "status_id")
  public static let rawStatus = ErronInfoLiteralKey(uncheckedString: "raw_status")
  
  public static let state = ErronInfoLiteralKey(uncheckedString: "state")
  public static let invalidState = ErronInfoLiteralKey(uncheckedString: "invalid_state")
  public static let unexpectedState = ErronInfoLiteralKey(uncheckedString: "unexpected_state")
  public static let sourceState = ErronInfoLiteralKey(uncheckedString: "source_state")
  public static let targetState = ErronInfoLiteralKey(uncheckedString: "target_state")
  
  public static let value = ErronInfoLiteralKey(uncheckedString: "value")
  public static let rawValue = ErronInfoLiteralKey(uncheckedString: "raw_value")
  public static let stringValue = ErronInfoLiteralKey(uncheckedString: "string_value")
  public static let uncheckedValue = ErronInfoLiteralKey(uncheckedString: "unchecked_value")
  public static let instance = ErronInfoLiteralKey(uncheckedString: "instance")
  public static let object = ErronInfoLiteralKey(uncheckedString: "object")
  
  public static let url = ErronInfoLiteralKey(uncheckedString: "url")
  public static let requestURL = ErronInfoLiteralKey(uncheckedString: "request_url")
  public static let responseURL = ErronInfoLiteralKey(uncheckedString: "response_url")
  public static let responseData = ErronInfoLiteralKey(uncheckedString: "response_data")
  public static let responseJson = ErronInfoLiteralKey(uncheckedString: "response_json")
  public static let dataString = ErronInfoLiteralKey(uncheckedString: "data_string")
  public static let dataBytesCount = ErronInfoLiteralKey(uncheckedString: "data_bytes_count")
  
  public static let index = ErronInfoLiteralKey(uncheckedString: "index")
  public static let indices = ErronInfoLiteralKey(uncheckedString: "indices")
  
  public static let errorCode = ErronInfoLiteralKey(uncheckedString: "error_code")
  public static let errorDomain = ErronInfoLiteralKey(uncheckedString: "error_domain")
  
  public static let file = ErronInfoLiteralKey(uncheckedString: "file")
  public static let line = ErronInfoLiteralKey(uncheckedString: "line")
  public static let fileLine = ErronInfoLiteralKey(uncheckedString: "file_line")
  public static let function = ErronInfoLiteralKey(uncheckedString: "function")
  
  public static let message = ErronInfoLiteralKey(uncheckedString: "message")
  public static let debugMessage = ErronInfoLiteralKey(uncheckedString: "debug_message")
  public static let description = ErronInfoLiteralKey(uncheckedString: "description")
  public static let debugDescription = ErronInfoLiteralKey(uncheckedString: "debug_description")
  
  public static let decodingDate = ErronInfoLiteralKey(uncheckedString: "decoding_date")
  public static let encodingDate = ErronInfoLiteralKey(uncheckedString: "encoding_date")
  
  public static let timestamp = ErronInfoLiteralKey(uncheckedString: "timestamp")
  public static let decodingTimestamp = ErronInfoLiteralKey(uncheckedString: "decoding_timestamp")
  public static let encodingTimestamp = ErronInfoLiteralKey(uncheckedString: "encoding_timestamp")
}
