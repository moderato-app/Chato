import Foundation

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
  if urlString.trimmingCharacters(in: .whitespaces).isEmpty{
    throw URLParsingError.invalidURL
  }
  
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
