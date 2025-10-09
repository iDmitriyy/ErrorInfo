# 🧩 ErrorInfo
> A Swift-native, type-safe, and `Sendable`-compliant alternative to `[String: Any]` for storing structured error details.
---
## 🚀 Why ErrorInfo?

While Swift has robust support for modeling errors through the `Error` protocol, the language lacks a native, structured, and thread-safe way to store **additional error context**.

In practice, `[String: Any]` is often used  for this, but this pattern suffers from serious drawbacks:
- ❌ **Not `Sendable`** – can't be safely used across concurrent contexts
- ❌ **Unsafe typing** – `Any` allows placing arbitrary, non-type-safe values
- ❌ **Loss of previous values** – inserting a value for an existing key overwrites the old one
- ❌ **Poor merging support** – key collisions can lead to data loss
- ❌ **Debugging complexity** – lacks built-in ordering or tracing mechanisms

### ✅ `ErrorInfo`

The `ErrorInfo` library introduces a family of structured, type-safe, and `Sendable` error info containers that:
- Maintain safe value types
- Support advanced merge strategies to avoid data loss
- Are compatible with Swift concurrency
- Provide ordered and unordered variants
- Allow merging, tracing, and resolving conflicts intelligently

## 📦 Library Overview

### Provided Types

| Type               | Backing Storage                   | Ordered | Sendable | Type of Value            |
|---------------------|----------------------------------|---------|----------|--------------------------|
| `ErrorInfo`         | `OrderedMultiValueDictionary`    |  ✅ Yes |  ✅ Yes | `any ErrorInfoValueType` |
| `LegacyErrorInfo`   | `Swift.Dictionary`               |  ❌ No  |  ❌ No  | `Any`                    |


*`any ErrorInfoValueType` is typeaias to `Sendable & Equatable & CustomStringConvertible`

This constraint ensures:
✅ Thread Safety via Sendable
✅ Meaningful Logging via CustomStringConvertible
✅ Collision Detection via Equatable

⚠️ Design Principles
✅ Safe merging without data loss
✅ Trackable value origins for logging & debugging
✅ No implicit value overwrites
✅ Type-safe values only

🧠 Design Highlights
🔁 Merging with Collision Resolution
Merging error-info containers is a core use case. The library supports two collision resolution strategies:
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

🧩 Value Collisions
Unlike dictionaries, ErrorInfo keeps all values.
```
var info: ErrorInfo = ["a": 1]
info["a"] = 1                        // ❌ Skipped (duplicate)
info.append(key: "a", 
            value: 1,
            insertIfEqual: true)     // ✅ Explicitly added
info["a"] = 2                        // ✅ Added (another value)
info["a"] = "2"                      // ✅ Added (different type)
info["a"] = 2.0                      // ✅ Added (different type)
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
