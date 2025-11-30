import Foundation
import os

/// Unified logging management system
/// Uses Apple's native OSLog, supports structured logging, sensitive information protection, and audit tracking
public final class AppLogger {
  
  // MARK: - Subsystem Definition
  
  /// Application identifier for OSLog subsystem
  private static let subsystem = Bundle.main.bundleIdentifier ?? "app.moderato.Chato.Chato"
  
  // MARK: - Log Categories
  
  /// Network request related logs
  public static let network = Logger(subsystem: subsystem, category: "network")
  
  /// UI interaction related logs
  public static let ui = Logger(subsystem: subsystem, category: "ui")
  
  /// Data processing logs
  public static let data = Logger(subsystem: subsystem, category: "data")
  
  /// Error and exception logs
  public static let error = Logger(subsystem: subsystem, category: "error")
  
  /// Security and audit logs
  public static let audit = Logger(subsystem: subsystem, category: "audit")
  
  
  // MARK: - Structured Error Logging
  
  /// Structured error information
  public struct ErrorContext {
    let error: Error
    let operation: String       // Failed operation
    let component: String        // Component where error occurred
    let userMessage: String?     // User-friendly message (optional)
    let metadata: [String: Any]? // Additional metadata
  }
  
  /// Log structured error
  /// - Parameter context: Error context
  /// - Returns: Returns user-friendly error message
  @discardableResult
  public static func logError(_ context: ErrorContext) -> String {
    // Internal debug information (full error)
    error.error("""
      [Error] Component:\(context.component) | \
      Operation:\(context.operation) | \
      Error:\(context.error.localizedDescription, privacy: .private) | \
      Metadata:\(context.metadata?.description ?? "{}", privacy: .private)
      """)
    
    // Return sanitized user message
    return context.userMessage ?? "Operation failed, please try again later"
  }
  
  
  // MARK: - Convenience Methods
  
  /// Log network request start
  public static func logNetworkRequest(url: String, method: String = "GET") {
    network.info("📤 Network request [\(method)] \(url, privacy: .public)")
  }
  
  /// Log network response
  public static func logNetworkResponse(url: String, statusCode: Int, duration: TimeInterval) {
    if (200..<300).contains(statusCode) {
      network.info("📥 Network response [\(statusCode)] \(url, privacy: .public) - Duration: \(duration, format: .fixed(precision: 3))s")
    } else {
      network.error("❌ Network error [\(statusCode)] \(url, privacy: .public) - Duration: \(duration, format: .fixed(precision: 3))s")
    }
  }
  
}

// MARK: - Extension: Convenient Error Context Builder

public extension AppLogger.ErrorContext {
  /// Quickly create error context from operation and error
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

