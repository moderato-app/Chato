// Created for Chato in 2024

import Foundation
import Testing

struct Test {
  @Test func example() async throws {
    let result = try parseURL("https://example.com/path/to/resource")
    #expect(result.base == "https://example.com")
    #expect(result.path == "path/to/resource")
  }

  @Test func example2() async throws {
    let result = try parseURL("http://example.com/path/to/resource")
    #expect(result.base == "http://example.com")
    #expect(result.path == "path/to/resource")
  }

  @Test func example3() async throws {
    let result = try parseURL("example.com/path/to/resource")
    #expect(result.base == "https://example.com")
    #expect(result.path == "path/to/resource")
  }

  @Test func example4() async throws {
    let result = try parseURL("192.168.0.1/path/to/resource")
    #expect(result.base == "https://192.168.0.1")
    #expect(result.path == "path/to/resource")
  }

  @Test func example5() async throws {
    let result = try parseURL("192.168.0.1/")
    #expect(result.base == "https://192.168.0.1")
    #expect(result.path == nil)
  }

  @Test func example6() async throws {
    let result = try parseURL("192.168.0.1/")
    #expect(result.base == "https://192.168.0.1")
    #expect(result.path == nil)
  }

  @Test func example7() async throws {
    let result = try parseURL("a.b.com/")
    #expect(result.base == "https://a.b.com")
    #expect(result.path == nil)
  }

  @Test func example9() async throws {
    let result = try parseURL("https://aa.bb/")
    #expect(result.base == "https://aa.bb")
    #expect(result.path == nil)
  }

  @Test func example8() async throws {
    let result = try parseURL("https://aa.bb/adf3")
    #expect(result.base == "https://aa.bb")
    #expect(result.path == "adf3")
  }
  
  @Test func example10() async throws {
    let result = try parseURL("192.168.0.1")
    #expect(result.base == "https://192.168.0.1")
    #expect(result.path == nil)
  }
  
  @Test func example11() async throws {
    let result = try parseURL("http://192.168.0.1")
    #expect(result.base == "http://192.168.0.1")
    #expect(result.path == nil)
  }
  
  @Test func example12() async throws {
    #expect(throws: URLParsingError.self){
      let result = try parseURL("/api")
    }
  }
}

/// Errors that can occur while parsing a URL
enum URLParsingError: Error, LocalizedError {
  case invalidURL
  case unsupportedScheme

  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "The provided string is not a valid URL."
    case .unsupportedScheme:
      return "Only HTTP and HTTPS schemes are supported."
    }
  }
}

/// Parses a URL string and extracts the base (scheme + host/IP) and path.
/// - Parameter urlString: The URL string to parse. It can be a host, IP, base URL, or URL with path.
/// - Throws: `URLParsingError` if the URL is invalid or has an unsupported scheme.
/// - Returns: A tuple containing the base URL and the path.
func parseURL(_ urlString: String) throws -> (base: String, path: String?) {
  var processedURLString = urlString

  // Check if the URL string contains a scheme; if not, prepend "http://"
  if !processedURLString.lowercased().starts(with: "http://") &&
    !processedURLString.lowercased().starts(with: "https://")
  {
    processedURLString = "https://" + processedURLString
  }

  // Attempt to create a URL object
  guard let url = URL(string: processedURLString) else {
    throw URLParsingError.invalidURL
  }

  // Ensure the scheme is either HTTP or HTTPS
  guard let scheme = url.scheme?.lowercased(),
        scheme == "http" || scheme == "https"
  else {
    throw URLParsingError.unsupportedScheme
  }

  // Ensure the host is present
  guard let host = url.host else {
    throw URLParsingError.invalidURL
  }

  // Extract the base URL
  let base = "\(scheme)://\(host)"

  // Extract the path, defaulting to nil if empty
  var path: String?
  if !url.path.isEmpty, url.path != "/" {
    path = url.path.trimmingCharacters(in: ["/"])
  }

  return (base, path)
}
