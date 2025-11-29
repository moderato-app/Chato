import Foundation
import os

/// 统一的日志管理系统
/// 使用 Apple 原生 OSLog，支持结构化日志、敏感信息保护和审计追踪
public final class AppLogger {
  
  // MARK: - Subsystem 定义
  
  /// 应用标识符，用于 OSLog subsystem
  private static let subsystem = Bundle.main.bundleIdentifier ?? "app.moderato.Chato.Chato"
  
  // MARK: - 日志分类
  
  /// 网络请求相关日志
  public static let network = Logger(subsystem: subsystem, category: "network")
  
  /// UI 交互相关日志
  public static let ui = Logger(subsystem: subsystem, category: "ui")
  
  /// 数据处理日志
  public static let data = Logger(subsystem: subsystem, category: "data")
  
  /// 错误和异常日志
  public static let error = Logger(subsystem: subsystem, category: "error")
  
  /// 安全和审计日志
  public static let audit = Logger(subsystem: subsystem, category: "audit")
  
  /// 性能监控日志
  public static let performance = Logger(subsystem: subsystem, category: "performance")
  
  // MARK: - 审计追踪
  
  /// 审计日志条目结构
  public struct AuditEntry {
    let timestamp: Date
    let actor: String          // 执行操作的主体（用户ID、会话ID等）
    let action: String          // 执行的操作
    let resource: String?       // 操作的资源（可选）
    let outcome: AuditOutcome   // 操作结果
    let details: [String: Any]? // 额外详情（可选）
    
    public enum AuditOutcome: String {
      case success = "成功"
      case failure = "失败"
      case partial = "部分成功"
    }
  }
  
  private static let iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()

  private static func jsonString(from dictionary: [String: Any]?) -> String {
    guard let dictionary = dictionary, !dictionary.isEmpty else { return "{}" }
    guard let data = try? JSONSerialization.data(withJSONObject: dictionary),
          let string = String(data: data, encoding: .utf8) else {
      return "{}"
    }
    return string
  }

  /// 记录审计日志
  /// - Parameter entry: 审计条目
  public static func logAudit(_ entry: AuditEntry) {
    let timestamp = Self.iso8601Formatter.string(from: entry.timestamp)
    let resource = entry.resource ?? "N/A"
    let details = Self.jsonString(from: entry.details)
  
    audit.notice("""
      [审计] 时间:\(timestamp) | \
      操作者:\(entry.actor, privacy: .private) | \
      动作:\(entry.action) | \
      资源:\(resource) | \
      结果:\(entry.outcome.rawValue) | \
      详情:\(details, privacy: .private)
      """)
  }
  
  // MARK: - 结构化错误日志
  
  /// 结构化错误信息
  public struct ErrorContext {
    let error: Error
    let operation: String       // 失败的操作
    let component: String        // 出错的组件
    let userMessage: String?     // 用户友好的消息（可选）
    let metadata: [String: Any]? // 附加元数据
  }
  
  /// 记录结构化错误
  /// - Parameter context: 错误上下文
  /// - Returns: 返回用户友好的错误消息
  @discardableResult
  public static func logError(_ context: ErrorContext) -> String {
    // 内部调试信息（完整错误）
    error.error("""
      [错误] 组件:\(context.component) | \
      操作:\(context.operation) | \
      错误:\(context.error.localizedDescription, privacy: .private) | \
      元数据:\(context.metadata?.description ?? "{}", privacy: .private)
      """)
    
    // 返回脱敏的用户消息
    return context.userMessage ?? "操作失败，请稍后重试"
  }
  
  // MARK: - 性能追踪
  
  /// 性能测量会话
  public class PerformanceSession {
    private let operation: String
    private let startTime: Date
    
    init(operation: String) {
      self.operation = operation
      self.startTime = Date()
      performance.debug("⏱️ 开始性能测量: \(operation)")
    }
    
    /// 结束性能测量
    public func end() {
      let duration = Date().timeIntervalSince(startTime)
      
      // 根据耗时选择日志级别
      if duration > 1.0 {
        performance.warning("⚠️ 性能警告: \(self.operation) 耗时 \(duration, format: .fixed(precision: 3))秒")
      } else {
        performance.info("✅ 性能测量: \(self.operation) 耗时 \(duration, format: .fixed(precision: 3))秒")
      }
    }
  }
  
  /// 开始性能测量
  /// - Parameter operation: 操作名称
  /// - Returns: 性能会话对象
  public static func startPerformanceTracking(_ operation: String) -> PerformanceSession {
    return PerformanceSession(operation: operation)
  }
  
  // MARK: - 数据验证日志
  
  /// 记录数据验证失败
  /// - Parameters:
  ///   - field: 字段名
  ///   - reason: 失败原因
  ///   - value: 原始值（会被标记为敏感）
  public static func logValidationFailure(field: String, reason: String, value: Any?) {
    data.warning("""
      [验证失败] 字段:\(field) | \
      原因:\(reason) | \
      值:\(String(describing: value), privacy: .private)
      """)
  }
  
  // MARK: - 便捷方法
  
  /// 记录网络请求开始
  public static func logNetworkRequest(url: String, method: String = "GET") {
    network.info("📤 网络请求 [\(method)] \(url, privacy: .public)")
  }
  
  /// 记录网络响应
  public static func logNetworkResponse(url: String, statusCode: Int, duration: TimeInterval) {
    if (200..<300).contains(statusCode) {
      network.info("📥 网络响应 [\(statusCode)] \(url, privacy: .public) - 耗时: \(duration, format: .fixed(precision: 3))秒")
    } else {
      network.error("❌ 网络错误 [\(statusCode)] \(url, privacy: .public) - 耗时: \(duration, format: .fixed(precision: 3))秒")
    }
  }
  
  /// 记录 UI 事件
  public static func logUIEvent(component: String, action: String, details: String? = nil) {
    if let details = details {
      ui.debug("🎯 UI事件 [\(component)] \(action) - \(details)")
    } else {
      ui.debug("🎯 UI事件 [\(component)] \(action)")
    }
  }
}

// MARK: - 扩展：便捷的审计日志构建器

public extension AppLogger.AuditEntry {
  /// 快速创建成功的审计条目
  static func success(
    actor: String,
    action: String,
    resource: String? = nil,
    details: [String: Any]? = nil
  ) -> AppLogger.AuditEntry {
    return AppLogger.AuditEntry(
      timestamp: Date(),
      actor: actor,
      action: action,
      resource: resource,
      outcome: .success,
      details: details
    )
  }
  
  /// 快速创建失败的审计条目
  static func failure(
    actor: String,
    action: String,
    resource: String? = nil,
    details: [String: Any]? = nil
  ) -> AppLogger.AuditEntry {
    return AppLogger.AuditEntry(
      timestamp: Date(),
      actor: actor,
      action: action,
      resource: resource,
      outcome: .failure,
      details: details
    )
  }
}

// MARK: - 扩展：便捷的错误上下文构建器

public extension AppLogger.ErrorContext {
  /// 从操作和错误快速创建错误上下文
  static func from(
    error: Error,
    operation: String,
    component: String,
    userMessage: String? = nil
  ) -> AppLogger.ErrorContext {
    return AppLogger.ErrorContext(
      error: error,
      operation: operation,
      component: component,
      userMessage: userMessage,
      metadata: nil
    )
  }
}

