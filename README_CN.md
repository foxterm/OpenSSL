# OpenSSL

[English](README.md) | [中文文档](README_CN.md)

FoxTerm APP 专用 OpenSSL 静态库，基于 [OpenSSL 4.0.3](https://github.com/openssl/openssl)，通过扫描 libssh 和 libvncserver 实际使用的 API 精确裁剪，追求最小二进制体积。

> 本库为 [FoxTerm](https://foxterm.app/) APP 专用核心组件，欢迎下载使用：[https://foxterm.app/](https://foxterm.app/)

## 特性

- **精确裁剪**：源码级扫描 libssh/libvncserver，仅保留实际调用的 API
- **极致体积优化**：`-Oz` 编译 + `-fvisibility=hidden` + `strip -x` 三级压缩
- **Out-of-tree 编译**：不拷贝源码树，构建更快
- **统一输出**：合并 `libssl.a` + `libcrypto.a` 为单库 `libopenssl.a`
- **多架构支持**：macOS (arm64/x86_64 universal)、iOS device (arm64)、iOS simulator (arm64)

## 保留的算法

| 类别 | 算法 | 使用者 |
|------|------|--------|
| 对称加密 | AES (CBC/CTR/GCM/ECB), DES/3DES, Blowfish, ChaCha20-Poly1305 | libssh, libvncserver |
| 摘要哈希 | SHA1, SHA256, SHA384, SHA512, MD5 | libssh, libvncserver |
| 公钥密码 | RSA, ECDSA, Ed25519/X25519, ECDH, DH | libssh |
| TLS/SSL | TLS 1.2+, X509 证书验证 | libvncserver |
| HMAC | HMAC-SHA1/256/384/512, HMAC-MD5 | libssh |

## 移除的内容

- **旧协议**：SSL3, TLS 1.0/1.1, DTLS 全系列
- **不需要的加密算法**：ARIA, Camellia, CAST, IDEA, RC2, RC5, SEED, SM2/3/4, Whirlpool, BLAKE2, RIPEMD160, MD4
- **不需要的功能**：OCB, CT, PSK, SRP, SRTP, SCRYPT, TS, CMS, GOST, KTLS, FIPS, Legacy provider
- **引擎/动态模块**：engine, static-engine, module
- **杂项**：filenames, pinshared, autoload-config, uplink, dgram

## 环境要求

| 平台 | 最低版本 |
|------|---------|
| iOS  | 17.0    |
| macOS | 14.0   |

## 快速开始

```bash
git clone https://github.com/foxterm/OpenSSL.git
cd OpenSSL
./build_xcframework.sh
```

构建产物位于 `xcframework/OpenSSL.xcframework`。

## 集成方式

其他 FoxTerm 子项目（SSH、VNC）通过相对路径引用此预编译产物：

```bash
OPENSSL_BUILD_DIR="$(pwd)/../OpenSSL/openssl_xcframework_build"
```

CMake 中指定：

```cmake
-DOPENSSL_ROOT_DIR="${OPENSSL_BUILD_DIR}/build/install_${target_id}"
-DOPENSSL_INCLUDE_DIR="${OPENSSL_BUILD_DIR}/build/install_${target_id}/include"
-DOPENSSL_LIBRARIES="${OPENSSL_BUILD_DIR}/build/install_${target_id}/lib/libssl.a;${OPENSSL_BUILD_DIR}/build/install_${target_id}/lib/libcrypto.a"
```

## CA 凭证管理

`CacertManager`（位于 `Sources/Cacert/`）内嵌 `cacert.pem`，并将其加载到 OpenSSL 的 `SSL_CTX` 中用于 TLS 证书验证。凭证路径优先从 `Bundle.module` 解析，其次回退到 Application Support 目录。

```swift
import OpenSSL

do {
    let ctx = SSL_CTX_new(TLS_client_method())
    try CacertManager.shared.configure(ctx)
} catch {
    // 這裡使用 FoxTerm 自己的日誌系統記錄錯誤
    logger.error("Failed to setup TLS CA certificates: \(error.localizedDescription, privacy: .public)")
}
```

### API

| 成员 | 说明 |
|---|---|
| `CacertManager.shared` | 全局单例实例 |
| `init(fileManager:bundle:)` | 支持依赖注入的初始化器，便于单元测试 |
| `certificatePath` | 解析后的 `cacert.pem` 绝对路径，未找到时为 `nil` |
| `configure(_ ctx:)` | 通过 `SSL_CTX_load_verify_locations` 将 CA 凭证加载到 `SSL_CTX`；失败时抛出 `OpenSSLCACertificateError` |

### 错误类型

| Case | 含义 |
|---|---|
| `.bundlePathNotFound` | 在 Bundle 或 Application Support 中未找到 `cacert.pem` |
| `.failedToSetVerifyLocations(path:opensslError:)` | OpenSSL 加载凭证文件失败 |
| `.invalidContextPointer` | 传入的 `SSL_CTX` 指针为 `nil` |

## 项目结构

```
OpenSSL/
├── build_xcframework.sh       # 构建脚本（体积优化版）
├── Sources/
│   └── Cacert/
│       ├── Cacert.swift        # CacertManager — CA 凭证加载器
│       └── Resources/
│           └── cacert.pem      # 内嵌 CA 凭证文件
└── xcframework/
    └── OpenSSL.xcframework/   # 预编译 xcframework（iOS + macOS）
        ├── Info.plist
        ├── ios-arm64/
        ├── ios-arm64-simulator/
        └── macos-arm64_x86_64/
```

## 许可证

Apache License 2.0
