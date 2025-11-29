import Foundation
import os

struct PromptSample: Decodable {
  enum CodingKeys: CodingKey {
    case languageCodes, prompts
  }

  let languageCodes: [String]
  let prompts: [Prompt]

  init() {
    self.languageCodes = .init()
    self.prompts = .init()
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.languageCodes = try container.decode([String].self, forKey: .languageCodes)
    self.prompts = try container.decode([Prompt].self, forKey: .prompts)
  }
}

extension PromptSample {
  
  static let userDefault = Prompt(
    name: "Emoji Chatbot",
    messages: [PromptMessage(content: "You will be provided with a message, and your task is to respond using emojis only.", role: .system, order: 0)],
    order: 0
  )

  static func english() -> PromptSample {
    do {
      guard let path = Bundle.main.path(forResource: "prompts", ofType: "json") else {
        fatalError("Failed to find prompts.json")
      }

      let url = URL(fileURLWithPath: path)

      let data = try Data(contentsOf: url)
      let promptSample = try JSONDecoder().decode(PromptSample.self, from: data)
      return promptSample
    } catch {
      AppLogger.logError(.from(
        error: error,
        operation: "加载提示词样本",
        component: "PromptSample",
        userMessage: nil
      ))
      return PromptSample()
    }
  }
}
