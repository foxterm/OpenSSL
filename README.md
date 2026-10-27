# OpenSSL

[English](README.md) | [中文文档](README_CN.md)

A size-optimized OpenSSL static library for the FoxTerm app — built from [OpenSSL 4.0.3](https://github.com/openssl/openssl) with algorithms precisely trimmed based on actual API usage in libssh and libvncserver.

> This library is a dedicated core component for the [FoxTerm](https://foxterm.app/) app. Download it here: [https://foxterm.app/](https://foxterm.app/)

## Requirements

| Platform | Minimum Version |
|----------|----------------|
| iOS      | 17.0           |
| macOS    | 14.0           |

## Build

The `OpenSSL.xcframework` is automatically built by [xcframework_build](https://github.com/foxterm/xcframework_build) CI/CD pipeline and pushed to this repository. Manual building is not required for normal usage.

## Integration

This library is consumed as a prebuilt XCFramework via Swift Package Manager or CocoaPods. The `OpenSSL.xcframework` at the repository root is automatically built and updated by [xcframework_build](https://github.com/foxterm/xcframework_build).

## CA Certificate Management

The `CacertManager` (in `Sources/Cacert/`) bundles a `cacert.pem` and applies it to an OpenSSL `SSL_CTX` for TLS certificate verification.

```swift
import Cacert

let ctx = SSL_CTX_new(TLS_client_method())
if CacertManager.shared.configure(ctx) {
    // CA certificates loaded successfully
} else {
    logger.error("Failed to setup TLS CA certificates")
}
```

### API

| Member | Description |
|---|---|
| `CacertManager.shared` | Global singleton instance |
| `certificatePath` | Absolute path to `cacert.pem`, or `nil` |
| `certificateContent` | Full text content of `cacert.pem` |
| `configure(_ ctx:)` | Loads CA bundle into `SSL_CTX`; returns `true` on success |

## Project Structure

```
OpenSSL/
├── Sources/
│   └── Cacert/
│       ├── Cacert.swift            # CacertManager — CA certificate loader
│       └── Resources/
│           └── cacert.pem          # Bundled CA certificate bundle
├── OpenSSL.xcframework/            # Precompiled xcframework (auto-built by CI)
└── Package.swift
```

## License

Apache License 2.0
