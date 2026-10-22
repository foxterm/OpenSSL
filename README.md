# OpenSSL

[English](README.md) | [中文文档](README_CN.md)

A size-optimized OpenSSL static library for the FoxTerm app — built from [OpenSSL 3.6.5](https://github.com/openssl/openssl) with algorithms precisely trimmed based on actual API usage in libssh and libvncserver.

> This library is a dedicated core component for the [FoxTerm](https://foxterm.app/) app. Download it here: [https://foxterm.app/](https://foxterm.app/)

## Features

- **Precision Trimming** — Source-code scanning of libssh/libvncserver to retain only used APIs
- **Aggressive Size Optimization** — `-Oz` compilation + `-fvisibility=hidden` + `strip -x`
- **Out-of-tree Builds** — No source tree copying, faster iteration
- **Single Library Output** — Merged `libssl.a` + `libcrypto.a` into one `libopenssl.a`
- **Multi-architecture** — macOS (arm64/x86_64 universal), iOS device (arm64), iOS simulator (arm64)

## Retained Algorithms

| Category | Algorithms | Used By |
|----------|-----------|---------|
| Symmetric | AES (CBC/CTR/GCM/ECB), DES/3DES, Blowfish, ChaCha20-Poly1305 | libssh, libvncserver |
| Hash | SHA1, SHA256, SHA384, SHA512, MD5 | libssh, libvncserver |
| Public Key | RSA, ECDSA, Ed25519/X25519, ECDH, DH | libssh |
| TLS/SSL | TLS 1.2+, X509 certificate verification | libvncserver |
| HMAC | HMAC-SHA1/256/384/512, HMAC-MD5 | libssh |

## Removed Content

- **Legacy protocols**: SSL3, TLS 1.0/1.1, DTLS family
- **Unused ciphers**: ARIA, Camellia, CAST, IDEA, RC2, RC5, SEED, SM2/3/4, Whirlpool, BLAKE2, RIPEMD160, MD4
- **Unused features**: OCB, CT, PSK, SRP, SRTP, SCRYPT, TS, CMS, GOST, KTLS, FIPS, Legacy provider
- **Engines / dynamic modules**: engine, static-engine, module
- **Miscellaneous**: filenames, pinshared, autoload-config, uplink, dgram

## Requirements

| Platform | Minimum Version |
|----------|----------------|
| iOS      | 17.0           |
| macOS    | 14.0           |

## Quick Start

```bash
git clone https://github.com/foxterm/OpenSSL.git
cd OpenSSL
./build_xcframework.sh
```

Build output: `xcframework/OpenSSL.xcframework`.

## Integration

Other FoxTerm subprojects (SSH, VNC) reference this precompiled artifact via relative path:

```bash
OPENSSL_BUILD_DIR="$(pwd)/../OpenSSL/openssl_xcframework_build"
```

In CMake:

```cmake
-DOPENSSL_ROOT_DIR="${OPENSSL_BUILD_DIR}/build/install_${target_id}"
-DOPENSSL_INCLUDE_DIR="${OPENSSL_BUILD_DIR}/build/install_${target_id}/include"
-DOPENSSL_LIBRARIES="${OPENSSL_BUILD_DIR}/build/install_${target_id}/lib/libssl.a;${OPENSSL_BUILD_DIR}/build/install_${target_id}/lib/libcrypto.a"
```

## Project Structure

```
OpenSSL/
├── build_xcframework.sh       # Build script (size-optimized)
└── xcframework/
    └── OpenSSL.xcframework/   # Precompiled xcframework (iOS + macOS)
        ├── Info.plist
        ├── ios-arm64/
        ├── ios-arm64-simulator/
        └── macos-arm64_x86_64/
```

## License

Apache License 2.0
