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
  
  /// Performance monitoring logs
  public static let performance = Logger(subsystem: subsystem, category: "performance")
  
  // MARK: - Audit Tracking
  
  /// Audit log entry structure
  public struct AuditEntry {
    let timestamp: Date
    let actor: String          // Entity performing the operation (user ID, session ID, etc.)
    let action: String          // Operation performed
    let resource: String?       // Resource being operated on (optional)
    let outcome: AuditOutcome   // Operation result
    let details: [String: Any]? // Additional details (optional)
    
    public enum AuditOutcome: String {
      case success = "success"
      case failure = "failure"
      case partial = "partial"
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

  /// Log audit entry
  /// - Parameter entry: Audit entry
  public static func logAudit(_ entry: AuditEntry) {
    let timestamp = Self.iso8601Formatter.string(from: entry.timestamp)
    let resource = entry.resource ?? "N/A"
    let details = Self.jsonString(from: entry.details)
  
    audit.notice("""
      [Audit] Time:\(timestamp) | \
      Actor:\(entry.actor, privacy: .private) | \
      Action:\(entry.action) | \
      Resource:\(resource) | \
      Outcome:\(entry.outcome.rawValue) | \
      Details:\(details, privacy: .private)
      """)
  }
  
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
  
  // MARK: - Performance Tracking
  
  /// Performance measurement session
  public class PerformanceSession {
    private let operation: String
    private let startTime: Date
    
    init(operation: String) {
      self.operation = operation
      self.startTime = Date()
      performance.debug("⏱️ Starting performance measurement: \(operation)")
    }
    
    /// End performance measurement
    public func end() {
      let duration = Date().timeIntervalSince(startTime)
      
      // Choose log level based on duration
      if duration > 1.0 {
        performance.warning("⚠️ Performance warning: \(self.operation) took \(duration, format: .fixed(precision: 3))s")
      } else {
        performance.info("✅ Performance measurement: \(self.operation) took \(duration, format: .fixed(precision: 3))s")
      }
    }
  }
  
  /// Start performance measurement
  /// - Parameter operation: Operation name
  /// - Returns: Performance session object
  public static func startPerformanceTracking(_ operation: String) -> PerformanceSession {
    return PerformanceSession(operation: operation)
  }
  
  // MARK: - Data Validation Logging
  
  /// Log data validation failure
  /// - Parameters:
  ///   - field: Field name
  ///   - reason: Failure reason
  ///   - value: Original value (will be marked as sensitive)
  public static func logValidationFailure(field: String, reason: String, value: Any?) {
    data.warning("""
      [Validation Failed] Field:\(field) | \
      Reason:\(reason) | \
      Value:\(String(describing: value), privacy: .private)
      """)
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
  
  /// Log UI event
  public static func logUIEvent(component: String, action: String, details: String? = nil) {
    if let details = details {
      ui.debug("🎯 UI event [\(component)] \(action) - \(details)")
    } else {
      ui.debug("🎯 UI event [\(component)] \(action)")
    }
  }
}

// MARK: - Extension: Convenient Audit Log Builder

public extension AppLogger.AuditEntry {
  /// Quickly create a successful audit entry
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
  
  /// Quickly create a failed audit entry
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

