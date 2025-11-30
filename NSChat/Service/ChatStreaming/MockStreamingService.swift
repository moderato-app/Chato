import Foundation
import os

/// Mock streaming service for testing and development
/// Simulates AI streaming responses character by character
class MockStreamingService: ChatStreamingServiceProtocol {
  // MARK: - Constants
  
  /// Default word count
  private nonisolated static let DEFAULT_WORD_COUNT = 50
  
  // MARK: - Properties
  
  /// Background queue for handling streaming requests
  private let streamingQueue = DispatchQueue(
    label: bundleName + ".mockstreaming",
    qos: .userInitiated
  )
  
  // MARK: - Public Methods
  
  func streamChatCompletion(
    messages: [ChatMessage],
    config: StreamingServiceConfig,
    onStart: @escaping () -> Void,
    onDelta: @escaping (String, String) -> Void,
    onComplete: @escaping (String) -> Void,
    onError: @escaping (Error) -> Void
  ) {
    streamingQueue.async {
      Task {
        // Priority: extract from messages, then config.wordCount, then default
        let wordCount = self.extractWordCountFromMessages(messages)
          ?? config.wordCount
          ?? Self.DEFAULT_WORD_COUNT
        
        AppLogger.network.info(
          "[MockStreamingService] 🚀 Starting mock streaming request - WordCount: \(wordCount)"
        )
        
        // Generate full text
        let fullText = self.generateMockText(wordCount: wordCount)
        let characters = Array(fullText)
        var currentIndex = 0
        var accumulatedText = ""
        
        // Notify start
        DispatchQueue.main.async {
          onStart()
        }
        
        // Simulate streaming output (5ms per character)
        let interval: TimeInterval = 0.005
        
        while currentIndex < characters.count {
          // Wait for specified interval
          try? await Task.sleep(for: .seconds(interval))
          
          let deltaChar = String(characters[currentIndex])
          accumulatedText += deltaChar
          currentIndex += 1
          
          // Callback with delta text (capture value before async to avoid concurrency issues)
          let currentAccumulated = accumulatedText
          DispatchQueue.main.async {
            onDelta(deltaChar, currentAccumulated)
          }
        }
        
        AppLogger.network.info(
          "[MockStreamingService] ✅ Mock streaming request completed - Total length: \(accumulatedText.count)"
        )
        
        // Notify completion
        DispatchQueue.main.async {
          onComplete(accumulatedText)
        }
      }
    }
  }
  
  // MARK: - Private Methods
  
  /// Extract first number from latest message as wordCount
  /// - Parameter messages: Message list
  /// - Returns: Extracted number, or nil if not found
  private nonisolated func extractWordCountFromMessages(_ messages: [ChatMessage]) -> Int? {
    // Extract number from latest message (last one)
    guard let latestMessage = messages.last else {
      return nil
    }
    return extractFirstNumber(from: latestMessage.content)
  }
  
  /// Extract first number from text
  /// - Parameter text: Input text
  /// - Returns: Extracted number, or nil if not found
  private nonisolated func extractFirstNumber(from text: String) -> Int? {
    // Use regex to match first number
    let pattern = #"\d+"#
    guard let regex = try? NSRegularExpression(pattern: pattern),
          let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
          let range = Range(match.range, in: text)
    else {
      return nil
    }
    
    let numberString = String(text[range])
    return Int(numberString)
  }
  
  /// Generate mock text
  private nonisolated func generateMockText(wordCount: Int) -> String {
    let sampleWords = [
      "artificial", "intelligence", "machine", "learning", "neural", "network",
      "algorithm", "data", "processing", "model", "training", "optimization",
      "deep", "learning", "computer", "vision", "natural", "language", "processing",
      "transformer", "attention", "mechanism", "token", "embedding", "layer",
      "gradient", "descent", "backpropagation", "activation", "function",
      "convolutional", "recurrent", "generative", "adversarial", "reinforcement",
      "supervised", "unsupervised", "classification", "regression", "clustering",
      "feature", "extraction", "dimension", "reduction", "overfitting", "regularization",
      "batch", "normalization", "dropout", "accuracy", "precision", "recall",
      "performance", "evaluation", "cross-validation", "hyperparameter", "tuning",
    ]
    
    let templateSentences = [
      "The development of %@ has revolutionized the field of %@.",
      "Recent advances in %@ demonstrate significant improvements in %@ capabilities.",
      "Understanding %@ is crucial for implementing effective %@ systems.",
      "The integration of %@ with %@ opens new possibilities for innovation.",
      "Modern approaches to %@ leverage sophisticated %@ techniques.",
      "Researchers are exploring how %@ can enhance %@ performance.",
      "The combination of %@ and %@ creates powerful synergies.",
      "Applications of %@ in %@ continue to expand rapidly.",
      "Optimizing %@ requires careful consideration of %@ parameters.",
      "The relationship between %@ and %@ is fundamental to understanding %@.",
    ]
    
    var words: [String] = []
    var currentCount = 0
    
    while currentCount < wordCount {
      // Randomly select a sentence template
      let template = templateSentences.randomElement()!
      
      // Fill template
      let word1 = sampleWords.randomElement()!
      let word2 = sampleWords.randomElement()!
      let word3 = sampleWords.randomElement()!
      
      var sentence = template.replacingOccurrences(
        of: "%@", with: word1, options: [], range: template.range(of: "%@")
      )
      if let range = sentence.range(of: "%@") {
        sentence.replaceSubrange(range, with: word2)
      }
      if let range = sentence.range(of: "%@") {
        sentence.replaceSubrange(range, with: word3)
      }
      
      let sentenceWords = sentence.components(separatedBy: " ")
      words.append(contentsOf: sentenceWords)
      currentCount += sentenceWords.count
      
      // If not reached target word count, add space as sentence separator
      if currentCount < wordCount {
        words.append(" ")
        currentCount += 1
      }
    }
    
    // Trim to target word count
    let finalWords = Array(words.prefix(wordCount))
    return finalWords.joined(separator: " ") + " ⚠️"
  }
}
