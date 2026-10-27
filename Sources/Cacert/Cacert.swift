// FoxTerm | Cacert.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by admin@foxterm.app

import Foundation
import OpenSSL

/// CA 凭证管理器，负责加载内嵌的 cacert.pem 并配置到 OpenSSL SSL_CTX
public final class CacertManager: Sendable {
    /// 全局共享实例
    public static let shared = CacertManager()

    private let cachedCertPath = Bundle.module.path(forResource: "cacert", ofType: "pem")

    /// 创建管理器实例
    public init() {}

    /// cacert.pem 的绝对路径，未找到时为 nil
    public var certificatePath: String? {
        cachedCertPath
    }

    /// cacert.pem 的完整文本内容
    public var certificateContent: String? {
        guard let cachedCertPath else { return nil }
        return try? String(contentsOfFile: cachedCertPath, encoding: .utf8)
    }

    /// 将 cacert.pem 加载到 OpenSSL SSL_CTX 用于 TLS 证书验证
    /// - Parameter ctx: OpenSSL SSL_CTX 指针
    /// - Returns: 成功返回 true，失败返回 false
    @discardableResult
    public func configure(_ ctx: OpaquePointer?) -> Bool {
        guard let ctx, let cachedCertPath else {
            return false
        }

        let result = cachedCertPath.withCString { cPath in
            SSL_CTX_load_verify_locations(ctx, cPath, nil)
        }

        return result == 1
    }
}
