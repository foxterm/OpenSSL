// FoxTerm | Cacert.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by admin@foxterm.app

import Foundation
import OpenSSL

/// OpenSSL CA 凭证管理与加载相关错误
public enum OpenSSLCACertificateError: LocalizedError, Sendable {
    case bundlePathNotFound
    case failedToSetVerifyLocations(path: String, opensslError: UInt32)
    case invalidContextPointer

    public var errorDescription: String? {
        switch self {
        case .bundlePathNotFound:
            return "The 'cacert.pem' bundle could not be located in the module bundle or application support directory."
        case let .failedToSetVerifyLocations(path, opensslError):
            return "OpenSSL failed to load verify locations from '\(path)'. OpenSSL error code: \(opensslError)."
        case .invalidContextPointer:
            return "The provided SSL_CTX pointer is invalid (nil)."
        }
    }
}

/// 轻量、高效且无副作用的 CA 凭证管理器
public final class CacertManager: Sendable {
    /// 标准全局共享实例
    public static let shared = CacertManager()

    private let cachedCertPath: String?

    /// 初始化管理器（支持依赖注入以利单元测试）
    /// - Parameters:
    ///   - fileManager: 用于检索文件系统的 FileManager
    ///   - bundle: 资源所在的 Bundle（默认使用 SPM 的 Bundle.module）
    public init(fileManager: FileManager = .default, bundle: Bundle = .module) {
        cachedCertPath = Self.locateCertificate(using: fileManager, bundle: bundle)
    }

    private static func locateCertificate(using fileManager: FileManager, bundle: Bundle) -> String? {
        // 1. 优先检查 SPM 的 Bundle.module 资源包
        if let path = bundle.path(forResource: "cacert", ofType: "pem") {
            return path
        }

        // 2. 备用方案：检查 Application Support（未来可支持动态更新下载凭证）
        if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let customPath = appSupport.appendingPathComponent("cacert.pem").path
            if fileManager.fileExists(atPath: customPath) {
                return customPath
            }
        }

        return nil
    }

    /// 目前生效的凭证文件绝对路径
    public var certificatePath: String? {
        return cachedCertPath
    }

    /// 读取 `cacert.pem` 的完整文本内容
    public var certificateContent: String? {
        guard let path = cachedCertPath else { return nil }
        return try? String(contentsOfFile: path, encoding: .utf8)
    }

    /// 将 `cacert.pem` 套用到 OpenSSL 的 `SSL_CTX` 中
    /// - Parameter ctx: OpenSSL 的 `SSL_CTX` 指针
    /// - Throws: `OpenSSLCACertificateError` 当路径丢失或 OpenSSL 加载失败时抛出错误
    public func configure(_ ctx: OpaquePointer?) throws {
        guard let ctx = ctx else {
            throw OpenSSLCACertificateError.invalidContextPointer
        }

        guard let path = cachedCertPath else {
            throw OpenSSLCACertificateError.bundlePathNotFound
        }

        let result = path.withCString { cPath in
            SSL_CTX_load_verify_locations(ctx, cPath, nil)
        }

        guard result == 1 else {
            let errCode = ERR_get_error()
            throw OpenSSLCACertificateError.failedToSetVerifyLocations(path: path, opensslError: errCode)
        }
    }
}
