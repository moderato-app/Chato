import Foundation
import SwiftOpenAI

extension OpenAIService {
  func hello(model: String) async throws -> String {
    let msgs: [ChatCompletionParameters.Message] = [.init(role: .user, content: .text("Hello"))]
    let parameters = ChatCompletionParameters(
      messages: msgs,
      model: .custom(model)
    )

    let result = try await self.startChat(parameters: parameters)
    return result.choices[0].message.content ?? ""
  }
}
