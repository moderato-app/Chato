import Foundation
import SwiftOpenAI

extension OpenAIService {
  func hello() async throws -> String {
    let msgs: [ChatCompletionParameters.Message] = [.init(role: .user, content: .text("Hello"))]
    let parameters = ChatCompletionParameters(
      messages: msgs,
      model: .gpt4omini,
      streamOptions: .init(includeUsage: false)
    )

    let result = try await self.startChat(parameters: parameters)
    return result.choices[0].message.content ?? ""
  }
}
