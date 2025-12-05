import Foundation
import AIProxy
import os

/// OpenAI streaming service
/// Handles streaming chat completion requests using AIProxySwift
class OpenAIStreamingService: ChatStreamingServiceProtocol {
  // MARK: - Properties
  
  /// Background queue for handling streaming requests
  private let streamingQueue = DispatchQueue(
    label: "com.chato.openaistreaming",
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
            "[OpenAIStreamingService] ❌ Config error: missing apiKey or modelID"
          )
          DispatchQueue.main.async {
            onError(NSError(
              domain: "OpenAIStreamingService",
              code: -1,
              userInfo: [NSLocalizedDescriptionKey: "Missing apiKey or modelID in config"]
            ))
          }
          return
        }
        
        do {
          AppLogger.network.info(
            "[OpenAIStreamingService] 🚀 Starting streaming request - Model: \(modelID)"
          )
          
          // Create OpenAI service (BYOK mode)
          let openAIService: OpenAIService
          if let endpoint = config.endpoint, !endpoint.isEmpty {
            do {
              let res = try parseURL(endpoint)
              openAIService = AIProxy.openAIDirectService(
                unprotectedAPIKey: apiKey,
                baseURL: res.base
              )
            } catch {
              AppLogger.logError(.from(
                error: error,
                operation: "Parse endpoint URL",
                component: "OpenAIStreamingService",
                userMessage: nil
              ))
              openAIService = AIProxy.openAIDirectService(unprotectedAPIKey: apiKey)
            }
          } else {
            openAIService = AIProxy.openAIDirectService(unprotectedAPIKey: apiKey)
          }
          
          // Convert messages to OpenAI format
          let inputItems = messages.map { message -> OpenAIResponse.Input.InputItem in
            switch message.type {
            case .user:
              return .message(role: .user, content: .text(message.content))
            case .assistant:
              return .message(role: .assistant,content: .text(message.content))
            case .system:
              return .message(role: .system ,content: .text(message.content))
            }
          }
          let input = OpenAIResponse.Input.items(inputItems)
          // Build request body
          let requestBody = OpenAICreateResponseRequestBody(
            input: input,
            model: modelID,
            stream: true,
            tools: [.webSearchPreview(OpenAICreateResponseRequestBody.WebSearchPreviewTool(
              searchContextSize: .low,
              userLocation: .none
            ))],
//            webSearchOptions: .init(searchContextSize: .medium, userLocation: .none)
          )
          
          // Notify start
          DispatchQueue.main.async {
            onStart()
          }
          
          // Initiate streaming request
          let stream = try await openAIService.createStreamingResponse(requestBody: requestBody, secondsToWait: 60
          )
          
          var accumulatedText = ""
          var isCompleted = false
          
          // Process streaming response
          for try await event in stream {
            switch event {
            // Text delta - most important event for streaming content
            case .outputTextDelta(let textDelta):
              accumulatedText += textDelta.delta
              
              let currentAccumulated = accumulatedText
              DispatchQueue.main.async {
                onDelta(textDelta.delta, currentAccumulated)
              }
              
              AppLogger.network.debug(
                "[OpenAIStreamingService] 📝 Text delta received - Length: \(textDelta.delta.count)"
              )
            
            // Response completed - marks successful completion
            case .responseCompleted(let completed):
              AppLogger.network.info(
                "[OpenAIStreamingService] ✅ Response completed - ID: \(completed.response.id ?? "unknown"), Total length: \(accumulatedText.count)"
              )
              
              isCompleted = true
              DispatchQueue.main.async {
                onComplete(accumulatedText)
              }
            
            // Error event - handle API errors
            case .error(let errorEvent):
              AppLogger.error.error(
                "[OpenAIStreamingService] ❌ Error event - Code: \(errorEvent.code), Message: \(errorEvent.message)"
              )
              
              DispatchQueue.main.async {
                onError(NSError(
                  domain: "OpenAIStreamingService",
                  code: -1,
                  userInfo: [NSLocalizedDescriptionKey: errorEvent.message]
                ))
              }
              break
            
            // Response failed - handle failed responses
            case .responseFailed(let failed):
              AppLogger.error.error(
                "[OpenAIStreamingService] ❌ Response failed - ID: \(failed.response.id ?? "unknown")"
              )
              
              DispatchQueue.main.async {
                onError(NSError(
                  domain: "OpenAIStreamingService",
                  code: -1,
                  userInfo: [NSLocalizedDescriptionKey: "Response failed"]
                ))
              }
              break
            
            // Lifecycle events - log for debugging
            case .responseCreated(let created):
              AppLogger.network.debug(
                "[OpenAIStreamingService] 🎬 Response created - ID: \(created.response.id ?? "unknown")"
              )
              
            case .responseInProgress:
              AppLogger.network.debug("[OpenAIStreamingService] 🔄 Response in progress")
              
            case .responseIncomplete:
              AppLogger.network.warning("[OpenAIStreamingService] ⚠️ Response incomplete")
            
            // Web search events - log search activity
            case .webSearchCallInProgress:
              AppLogger.network.info("[OpenAIStreamingService] 🔍 Web search in progress")
              
            case .webSearchCallSearching:
              AppLogger.network.info("[OpenAIStreamingService] 🔍 Web search searching")
              
            case .webSearchCallCompleted:
              AppLogger.network.info("[OpenAIStreamingService] ✅ Web search completed")
            
            // Output item events - track output structure
            case .outputItemAdded(let item):
              AppLogger.network.debug(
                "[OpenAIStreamingService] ➕ Output item added - Index: \(item.index ?? -1)"
              )
              
            case .outputItemDone(let item):
              AppLogger.network.debug(
                "[OpenAIStreamingService] ✓ Output item done - Index: \(item.outputIndex ?? -1)"
              )
            
            // Content part events - track content structure
            case .contentPartAdded(let part):
              AppLogger.network.debug(
                "[OpenAIStreamingService] ➕ Content part added - Index: \(part.contentIndex ?? -1)"
              )
              
            case .contentPartDone(let part):
              AppLogger.network.debug(
                "[OpenAIStreamingService] ✓ Content part done - Index: \(part.contentIndex ?? -1)"
              )
            
            // Text completion - marks end of text
            case .outputTextDone(let textDone):
              AppLogger.network.debug(
                "[OpenAIStreamingService] ✓ Text done - Length: \(textDone.text.count)"
              )
            
            // Refusal events - log when model refuses
            case .refusalDelta(let refusal):
              AppLogger.network.warning(
                "[OpenAIStreamingService] 🚫 Refusal delta: \(refusal.delta)"
              )
              
            case .refusalDone(let refusal):
              AppLogger.network.warning(
                "[OpenAIStreamingService] 🚫 Refusal: \(refusal.refusal)"
              )
            
            // Function call events - log function calling activity
            case .functionCallArgumentsDelta(let args):
              AppLogger.network.debug(
                "[OpenAIStreamingService] 🔧 Function args delta - Length: \(args.delta.count)"
              )
              
            case .functionCallArgumentsDone(let args):
              AppLogger.network.debug(
                "[OpenAIStreamingService] ✓ Function args done - Length: \(args.arguments.count)"
              )
            
            // File search events - log file search activity
            case .fileSearchCallInProgress:
              AppLogger.network.info("[OpenAIStreamingService] 📁 File search in progress")
              
            case .fileSearchCallSearching:
              AppLogger.network.info("[OpenAIStreamingService] 📁 File search searching")
              
            case .fileSearchCallCompleted:
              AppLogger.network.info("[OpenAIStreamingService] ✅ File search completed")
            
            // Reasoning events - log reasoning process
            case .reasoningDelta(let reasoning):
              AppLogger.network.debug(
                "[OpenAIStreamingService] 🧠 Reasoning delta - Length: \(reasoning.delta.count)"
              )
              
            case .reasoningDone(let reasoning):
              AppLogger.network.debug(
                "[OpenAIStreamingService] ✓ Reasoning done - Length: \(reasoning.reasoning.count)"
              )
            
            // Other events we don't need to handle but log for debugging
            case .outputTextAnnotationAdded:
              AppLogger.network.debug("[OpenAIStreamingService] 📎 Text annotation added")
              
            case .audioDelta, .audioDone, .audioTranscriptDelta, .audioTranscriptDone:
              AppLogger.network.debug("[OpenAIStreamingService] 🎵 Audio event")
              
            case .codeInterpreterCallProgress:
              AppLogger.network.debug("[OpenAIStreamingService] 💻 Code interpreter progress")
              
            case .computerCallProgress:
              AppLogger.network.debug("[OpenAIStreamingService] 🖥️ Computer call progress")
              
            case .reasoningSummaryPartAdded, .reasoningSummaryPartDone,
                 .reasoningSummaryTextDelta, .reasoningSummaryTextDone,
                 .reasoningSummaryDelta, .reasoningSummaryDone:
              AppLogger.network.debug("[OpenAIStreamingService] 📊 Reasoning summary event")
              
            case .imageGenerationCallProgress, .imageGenerationCallPartialImage:
              AppLogger.network.debug("[OpenAIStreamingService] 🎨 Image generation event")
              
            case .mcpCallArgumentsDelta, .mcpCallArgumentsDone,
                 .mcpCallProgress, .mcpListToolsProgress:
              AppLogger.network.debug("[OpenAIStreamingService] 🔌 MCP event")
              
            case .responseQueued:
              AppLogger.network.debug("[OpenAIStreamingService] ⏳ Response queued")
            }
          }
          
          // If loop ended without completion event, call onComplete anyway
          if !isCompleted && accumulatedText.isEmpty == false {
            AppLogger.network.info(
              "[OpenAIStreamingService] ✅ Stream ended without completion event - Total length: \(accumulatedText.count)"
            )
            DispatchQueue.main.async {
              onComplete(accumulatedText)
            }
          }
          
        } catch AIProxyError.unsuccessfulRequest(let statusCode, let responseBody) {
          let errorMessage = "OpenAI API Error: \(statusCode) - \(responseBody)"
          AppLogger.error.error(
            "[OpenAIStreamingService] ❌ API request failed: \(errorMessage)"
          )
          
          DispatchQueue.main.async {
            onError(NSError(
              domain: "OpenAIStreamingService",
              code: statusCode,
              userInfo: [NSLocalizedDescriptionKey: errorMessage]
            ))
          }
          
        } catch {
          AppLogger.error.error(
            "[OpenAIStreamingService] ❌ Streaming request failed: \(error.localizedDescription)"
          )
          
          DispatchQueue.main.async {
            onError(error)
          }
        }
      }
    }
  }
}

