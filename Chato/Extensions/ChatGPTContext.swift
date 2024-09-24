import Foundation
import OpenAI

struct ChatGPTContext {
  let client: OpenAIProtocol

  init(apiKey: String, proxyHost: String = defulatHost, timeout: Double = 120.0) {
    let configuration = OpenAI.Configuration(token: apiKey, host: proxyHost, timeoutInterval: timeout)
    self.client = OpenAI(configuration: configuration)
  }

  func ask(input: String, chat: Chat, consume: @escaping (String, Error?) -> Void) {
    let query = ChatQuery( model: chat.option.model,messages: [.init(role: .user, content: input)])

    self.client.chatsStream(query: query) { partialResult in
      switch partialResult {
      case .success(let result):
        consume(result.choices[0].delta.content ?? "", nil)
        print(result.choices[0].delta.content ?? "", terminator: "")
      case .failure(let error):
        consume("", error)
        print(error)
      }
    } completion: { error in
      if let error = error {
        consume("", error)
        print(error)
      }
    }
  }

  func hello() async throws -> String {
    let query = ChatQuery(model: defaultGPTModel.value,messages: [.init(role: .user, content: "Hello")])

    let result = try await self.client.chats(query: query)
    return result.choices[0].message.content ?? ""
  }
}

struct AskOptions {
  let model: ChatGPTModel = defaultGPTModel
}

extension ChatGPTContext {
  public static let defulatHost = "api.openai.com"
}
