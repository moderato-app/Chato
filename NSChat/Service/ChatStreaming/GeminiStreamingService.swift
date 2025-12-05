import Foundation
import AIProxy
import os

/// Gemini streaming service
/// Handles streaming chat completion requests using AIProxySwift
class GeminiStreamingService: ChatStreamingServiceProtocol {
  // MARK: - Properties
  
  /// Background queue for handling streaming requests
  private let streamingQueue = DispatchQueue(
    label: "com.chato.geministreaming",
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
        // Validate required config parameters
        guard let apiKey = config.apiKey, let modelID = config.modelID else {
          AppLogger.error.error(
            "[GeminiStreamingService] ❌ Config error: missing apiKey or modelID"
          )
          DispatchQueue.main.async {
            onError(NSError(
              domain: "GeminiStreamingService",
              code: -1,
              userInfo: [NSLocalizedDescriptionKey: "Missing apiKey or modelID in config"]
            ))
          }
          return
        }
        
        do {
          AppLogger.network.info(
            "[GeminiStreamingService] 🚀 Starting streaming request - Model: \(modelID)"
          )
          
          // Create Gemini service (BYOK mode)
          // Note: Gemini doesn't support custom endpoints like OpenAI, so we always use direct service
          let geminiService = AIProxy.geminiDirectService(unprotectedAPIKey: apiKey)
          
          // Extract system message if present (Gemini uses systemInstruction for system messages)
          let systemMessages = messages.filter { $0.type == .system }
          let systemInstruction: GeminiGenerateContentRequestBody.SystemInstruction?
          if let systemMessage = systemMessages.first {
            systemInstruction = GeminiGenerateContentRequestBody.SystemInstruction(
              parts: [.text(systemMessage.content)]
            )
          } else {
            systemInstruction = nil
          }
          
          // Convert non-system messages to Gemini format
          let contents = messages
            .filter { $0.type != .system } // Exclude system messages (handled by systemInstruction)
            .map { message -> GeminiGenerateContentRequestBody.Content in
              let role: String
              switch message.type {
              case .user:
                role = "user"
              case .assistant:
                role = "model"
              case .system:
                role = "user" // Should not reach here due to filter above
              }
              
              return GeminiGenerateContentRequestBody.Content(
                parts: [.text(message.content)],
                role: role
              )
            }
          
          // Build request body with Google Search enabled
          let requestBody = GeminiGenerateContentRequestBody(
            contents: contents,
            cachedContent: nil,
            generationConfig: nil,
            safetySettings: nil,
            systemInstruction: systemInstruction,
            toolConfig: nil,
            tools: [.googleSearch(.init())] // Enable Google Search
          )
          
          // Notify start
          DispatchQueue.main.async {
            onStart()
          }
          
          // Initiate streaming request
          let stream = try await geminiService.generateStreamingContentRequest(
            body: requestBody,
            model: modelID,
            secondsToWait: 60
          )
          
          var accumulatedText = ""
          var lastProcessedTextLength = 0
          var isCompleted = false
          
          // Process streaming response
          for try await chunk in stream {
            // Extract text from candidates
            if let candidate = chunk.candidates?.first,
               let content = candidate.content,
               let parts = content.parts {
              
              // Extract all text parts and combine them
              var chunkText = ""
              for part in parts {
                if case .text(let text) = part {
                  chunkText += text
                }
              }
              
              // Calculate delta (new text since last chunk)
              // Gemini streaming returns cumulative text, so we need to extract the delta
              if chunkText.count > lastProcessedTextLength {
                let startIndex = chunkText.index(chunkText.startIndex, offsetBy: lastProcessedTextLength)
                let delta = String(chunkText[startIndex...])
                accumulatedText += delta
                
                let currentAccumulated = accumulatedText
                DispatchQueue.main.async {
                  onDelta(delta, currentAccumulated)
                }
                
                AppLogger.network.debug(
                  "[GeminiStreamingService] 📝 Text delta received - Length: \(delta.count), Total: \(chunkText.count): \(chunkText)"
                )
                
                lastProcessedTextLength = chunkText.count
              }
              
              // Check for grounding metadata (search results)
              if let groundingMetadata = candidate.groundingMetadata {
                if let webSearchQueries = groundingMetadata.webSearchQueries, !webSearchQueries.isEmpty {
                  AppLogger.network.info(
                    "[GeminiStreamingService] 🔍 Web search queries: \(webSearchQueries.joined(separator: ", "))"
                  )
                }
                
                if let groundingChunks = groundingMetadata.groundingChunks, !groundingChunks.isEmpty {
                  AppLogger.network.info(
                    "[GeminiStreamingService] ✅ Found \(groundingChunks.count) search result chunks"
                  )
                  
                  // Log search result URLs
                  for (index, chunk) in groundingChunks.enumerated() {
                    if let web = chunk.web, let uri = web.uri {
                      AppLogger.network.debug(
                        "[GeminiStreamingService] 📎 Search result \(index + 1): \(uri)"
                      )
                    }
                  }
                }
              }
            }
            
            // Check if completed
            if let candidate = chunk.candidates?.first,
               let finishReason = candidate.finishReason,
               !finishReason.isEmpty {
              
              AppLogger.network.info(
                "[GeminiStreamingService] ✅ Streaming request completed - Reason: \(finishReason), Total length: \(accumulatedText.count)"
              )
              
              isCompleted = true
              DispatchQueue.main.async {
                onComplete(accumulatedText)
              }
              break
            }
            
            // Log usage metadata if available
            if let usageMetadata = chunk.usageMetadata {
              AppLogger.network.debug(
                "[GeminiStreamingService] 📊 Usage - Total tokens: \(usageMetadata.totalTokenCount ?? 0)"
              )
            }
          }
          
          // If loop ended without completion event, call onComplete anyway
          if !isCompleted && accumulatedText.isEmpty == false {
            AppLogger.network.info(
              "[GeminiStreamingService] ✅ Stream ended without completion event - Total length: \(accumulatedText.count)"
            )
            DispatchQueue.main.async {
              onComplete(accumulatedText)
            }
          }
          
        } catch AIProxyError.unsuccessfulRequest(let statusCode, let responseBody) {
          let errorMessage = "Gemini API Error: \(statusCode) - \(responseBody)"
          AppLogger.error.error(
            "[GeminiStreamingService] ❌ API request failed: \(errorMessage)"
          )
          
          DispatchQueue.main.async {
            onError(NSError(
              domain: "GeminiStreamingService",
              code: statusCode,
              userInfo: [NSLocalizedDescriptionKey: errorMessage]
            ))
          }
          
        } catch {
          AppLogger.error.error(
            "[GeminiStreamingService] ❌ Streaming request failed: \(error.localizedDescription)"
          )
          
          DispatchQueue.main.async {
            onError(error)
          }
        }
      }
    }
  }
}
