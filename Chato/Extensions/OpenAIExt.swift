import Foundation
import AIProxy

fileprivate let timeout: UInt = 60
extension OpenAIService {
  func hello(model: String) async throws -> String {
    let msgs: [OpenAIChatCompletionRequestBody.Message] = [.user(content: .text("Hello"))]
    let parameters = OpenAIChatCompletionRequestBody(
      model: model,
      messages: msgs
    )

    let result = try await self.chatCompletionRequest(body: parameters, secondsToWait: timeout)
    return result.choices[0].message.content ?? ""
  }
}
