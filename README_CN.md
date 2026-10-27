# OpenSSL

[English](README.md) | [中文文档](README_CN.md)

FoxTerm APP 专用 OpenSSL 静态库，基于 [OpenSSL 4.0.3](https://github.com/openssl/openssl)，通过扫描 libssh 和 libvncserver 实际使用的 API 精确裁剪，追求最小二进制体积。

> 本库为 [FoxTerm](https://foxterm.app/) APP 专用核心组件，欢迎下载使用：[https://foxterm.app/](https://foxterm.app/)

## 环境要求

| 平台 | 最低版本 |
|------|---------|
| iOS  | 17.0    |
| macOS | 14.0   |

## 构建

`OpenSSL.xcframework` 由 [xcframework_build](https://github.com/foxterm/xcframework_build) CI/CD 流水线自动编译并推送到本仓库，正常使用无需手动构建。

## 集成方式

本库通过 Swift Package Manager 或 CocoaPods 以预编译 XCFramework 形式消费。仓库根目录的 `OpenSSL.xcframework` 由 [xcframework_build](https://github.com/foxterm/xcframework_build) 自动编译和更新。

## CA 凭证管理

`CacertManager`（位于 `Sources/Cacert/`）内嵌 `cacert.pem`，并将其加载到 OpenSSL 的 `SSL_CTX` 中用于 TLS 证书验证。

```swift
import Cacert

let ctx = SSL_CTX_new(TLS_client_method())
if CacertManager.shared.configure(ctx) {
    // CA 凭证加载成功
} else {
    logger.error("Failed to setup TLS CA certificates")
}
```

### API

| 成员 | 说明 |
|---|---|
| `CacertManager.shared` | 全局单例实例 |
| `certificatePath` | `cacert.pem` 的绝对路径，未找到时为 `nil` |
| `certificateContent` | `cacert.pem` 的完整文本内容 |
| `configure(_ ctx:)` | 将 CA 凭证加载到 `SSL_CTX`；成功返回 `true` |

## 项目结构

```
OpenSSL/
├── Sources/
│   └── Cacert/
│       ├── Cacert.swift            # CacertManager — CA 凭证加载器
│       └── Resources/
│           └── cacert.pem          # 内嵌 CA 凭证文件
├── OpenSSL.xcframework/            # 预编译 xcframework（CI 自动构建）
└── Package.swift
```

## 许可证

Apache License 2.0
