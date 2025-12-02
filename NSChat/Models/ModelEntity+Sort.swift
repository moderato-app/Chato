import Foundation
import SwiftData

extension ModelEntity {
  
  /// Smart sort Models
  /// Sorting rules:
  /// 1. Favorited models come first
  /// 2. Custom models come first (after favorited)
  /// 3. Extract numbers from name, larger numbers come first
  /// 4. If numbers are the same, more numbers come first
  /// 5. If numbers are identical, sort alphabetically
  static func smartSort(_ models: [ModelEntity]) -> [ModelEntity] {
    sortModels(models, prioritizeFavorited: true, prioritizeCustom: true)
  }
  
  /// Sort models by version numbers and name, without favorited priority
  /// Sorting rules:
  /// 1. Custom models come first
  /// 2. Extract numbers from name, larger numbers come first
  /// 3. If numbers are the same, more numbers come first
  /// 4. If numbers are identical, sort alphabetically
  static func versionSort(_ models: [ModelEntity]) -> [ModelEntity] {
    sortModels(models, prioritizeFavorited: false, prioritizeCustom: true)
  }
  
  /// Internal sort implementation
  /// - Parameters:
  ///   - models: Models to sort
  ///   - prioritizeFavorited: Whether to prioritize favorited models
  ///   - prioritizeCustom: Whether to prioritize custom models
  /// - Returns: Sorted models array
  private static func sortModels(_ models: [ModelEntity], prioritizeFavorited: Bool, prioritizeCustom: Bool) -> [ModelEntity] {
    // Pre-process: extract numbers once for each model to avoid repeated calculations
    let modelsWithNumbers = models.map { model in
      (model: model, numbers: extractNumbers(from: model.resolvedName))
    }
    
    // Sort
    let sorted = modelsWithNumbers.sorted { item1, item2 in
      let model1 = item1.model
      let model2 = item2.model
      let numbers1 = item1.numbers
      let numbers2 = item2.numbers
      
      // Rule 1: Favorited models come first (optional)
      if prioritizeFavorited && model1.favorited != model2.favorited {
        return model1.favorited && !model2.favorited
      }
      
      // Rule 2: Custom models come first (after favorited if enabled)
      if prioritizeCustom && model1.isCustom != model2.isCustom {
        return model1.isCustom && !model2.isCustom
      }
      
      // Rule 3: Compare version numbers
      // Compare numbers one by one
      let minCount = min(numbers1.count, numbers2.count)
      for i in 0..<minCount {
        if numbers1[i] != numbers2[i] {
          return numbers1[i] > numbers2[i] // Larger numbers come first
        }
      }
      
      // If previous numbers are the same, more numbers come first
      if numbers1.count != numbers2.count {
        return numbers1.count > numbers2.count
      }
      
      // If numbers are identical, sort alphabetically
      return model1.resolvedName < model2.resolvedName
    }
    
    // Return sorted model array
    return sorted.map { $0.model }
  }
  
  /// Cached regular expression to avoid repeated creation
  private static let numberRegex: NSRegularExpression? = {
    try? NSRegularExpression(pattern: #"\d+(\.\d+)?"#, options: [])
  }()
  
  /// Extract all numbers from string (supports decimal points)
  /// Example: "gpt-4.5-turbo" -> [4.5]
  ///          "claude-3.5-sonnet-20241022" -> [3.5, 20241022]
  private static func extractNumbers(from string: String) -> [Double] {
    guard let regex = numberRegex else {
      return []
    }
    
    var numbers: [Double] = []
    let range = NSRange(string.startIndex..., in: string)
    let matches = regex.matches(in: string, options: [], range: range)
    
    for match in matches {
      if let range = Range(match.range, in: string) {
        let numberString = String(string[range])
        if let number = Double(numberString) {
          numbers.append(number)
        }
      }
    }
    
    return numbers
  }
}

