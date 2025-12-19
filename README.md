# 🧩 ErrorInfo

<p align="left">
<img src="https://img.shields.io/badge/platforms-iOS%2C%20macOS%2C%20watchOS%2C%20tvOS%2C%20visionOS%2C%20macCatalyst-lightgrey.svg">
<img src="https://img.shields.io/badge/Licence-MIT-green">
</p>

> A Swift-native, type-safe and concurrency-compliant alternative to `[String: Any]` for storing structured error details.

*(currently is prepared for release 0.1.0)*

## 🚀 Why ErrorInfo?

While Swift has robust support for modeling errors through the `Error` protocol, the language lacks a native, structured, and thread-safe way to store **additional error context**.

In practice, `[String: Any]` is often used  for this, but this pattern suffers from serious drawbacks:
- ❌ **Not compatible with modern concurrency** – can't be safely used across concurrent contexts
- ❌ **Unsafe typing** – `Any` allows placing arbitrary, non-type-safe values
- ❌ **Loss of previous values** – inserting a value for an existing key overwrites the old one
- ❌ **Poor merging support** – key collisions can lead to data loss
- ❌ **Debugging complexity** – lacks built-in ordering or tracing mechanisms

### ✅ `ErrorInfo`

The `ErrorInfo` library introduces a family of structured, type-safe, and `Sendable` error info containers that:
- Provide checking values for safety at compile time
- Support advanced merge strategies to avoid data loss
- Are compatible with Swift concurrency
- Provide ordered and unordered variants
- Allow merging, tracing, and resolving conflicts intelligently

#### ⚠️ Design Principles
- ✅ Safe merging without data loss
- ✅ Trackable value origins for logging & debugging
- ✅ No implicit value overwrites
- ✅ Type-safe values only

## 📦 Library Overview

### Provided Types

| Feature                    |        `ErrorInfo`        |     `LegacyErrorInfo`     | `[String: Any]` |
|----------------------------|---------------------------|---------------------------|---------------|
| Collision Resolution       | ✅ Yes (store all values) | ☑️ Yes (key augmentation) | ❌ No        |
| Prevent implicit overwrite | ✅ No                     | ✅ No                     | ❌ Yes       |
| Prevent equal values       | ✅ Yes                    | ✅ Yes                    | －            |
| Preserve nil values        | ✅ Yes                    | ✅ Yes                    | ❌ No        |
| Collision source           | ✅ Yes                    | ✅ Yes                    | ❌ No        |
| Type info                  | ✅ Yes                    | ✅ Yes                    | ❌ No        |
| Merge                      | ✅ Yes                    | ☑️ Yes                    | 💥 Data loss |
| Key transform              | ✅ Yes                    | ☑️ Yes                    | 💥 Data loss |
| Sendable                   | ✅ Yes                    | ❌ No                     | ❌ No        |
| Ordered                    |    Yes                    |     No                     |    No        |
| Type of Value              | `ErrorInfo.ValueExistential`  |            `Any`          |     `Any`     |

*`ErrorInfo.ValueExistential` is typeaias to `Sendable & Equatable & CustomStringConvertible`

This constraint ensures:
- ✅ Thread Safety via Sendable
- ✅ Meaningful Logging via CustomStringConvertible
- ✅ Collision Detection via Equatable

#### 🧠 Design Highlights
🔁 Merging with Collision Resolution
The library supports two collision resolution strategies:
- Multiple Values per Key – preserve all values
- Key Augmentation – append suffixes (e.g., error domain, code) to conflicting keys

Example:
```swift
let e1: ErrorInfo = ["key": 1]
let e2: ErrorInfo = ["key": "A"]
let merged = e1.merged(with: e2)

// result: [1, "A"]
let allValues = merged.allValues(forKey: "key")
```

Or with key augmentation: TBD

🧩 Example: value collisions, no implicit overwrite, prevent equal values, preserve nil values 

Unlike dictionaries, ErrorInfo keeps all values.
```
var info: ErrorInfo = ["a": 1]
info["a"] = 1                     // ❌ Skipped (duplicate)
info["a"] = 2                     // ✅ Added (another value)
info["a"] = "2"                   // ✅ Added (different type)
info["a"] = nil Optional<Decimal> // ✅ Added (nil value)

info.appendIfNotNil(3 as Optional,
                    forKey: "a")  // ✅ added (non-nil another value)

allValues(forKey: "a")             // 1, 2, "2", 3
allValuesWithMetaInfo(forKey: "a") // 1, 2, "2", nil, 3
```

🧪 Example Use Case

Merging Multiple Errors
TBD


🔐 Non-Sendable & AnyObject Storage
Storing non-Sendable or AnyObject values is explicitly not supported in ErrorInfo.
If needed, use a separate, opt-in container like TransferableStorage (prototype available in [Sources]).

📦 Installation
.package(url: "https://github.com/iDmitriyy/ErrorInfo", branch: "main")

🧪 Tests (TBD after api surface become stable)
All collision detection, value comparison, and merge behaviors are covered in unit tests.

📣 Contributing
Contributions are welcome! If you have ideas, optimizations, or find a bug — feel free to open an issue or submit a PR.

<details>
  <summary>ErrorInfo details</summary>
  
  ```swift
  
  ```
  
</details>
