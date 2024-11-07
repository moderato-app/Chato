import Foundation

struct ChatGPTModel: Hashable {
  let name: String
  let value: String
  let version: Int

  init(_ name: String, _ value: String, _ version: Int) {
    self.name = name
    self.value = value
    self.version = version
  }
}

let chatGPTModels = [
  ChatGPTModel("GPT3.5 Turbo", "gpt-3.5-turbo", 3),
  defaultGPTModel,
  ChatGPTModel("GPT4", "gpt-4", 4),
  ChatGPTModel("GPT-4o", "gpt-4o", 4),
  ChatGPTModel("o1-preview", "o1-preview", 4),
  ChatGPTModel("o1-mini", "o1-mini", 4),
  ChatGPTModel("GPT-4 Turbo", "gpt-4-turbo", 4),
].sorted { a, b in a.value < b.value }

let defaultGPTModel = ChatGPTModel("GPT-4o mini", "gpt-4o-mini", 3)

enum ContextLength: Hashable {
  case zero
  case one
  case two
  case three
  case four
  case six
  case eight
  case ten
  case twenty
  case number(Int)
  case infinite

  var length: Int {
    switch self {
    case .zero:
      return 0
    case .one:
      return 1
    case .two:
      return 2
    case .three:
      return 3
    case .four:
      return 4
    case .six:
      return 6
    case .eight:
      return 8
    case .ten:
      return 10
    case .twenty:
      return 20
    case .number(let n):
      return n
    case .infinite:
      return Int.max
    }
  }

  var lengthString: String {
    if self == .infinite {
      return "Inf"
    } else {
      return "\(self.length)"
    }
  }
}

let contextLengthChoices = [
  ContextLength.zero,
  ContextLength.one,
  ContextLength.two,
  ContextLength.three,
  ContextLength.four,
  ContextLength.six,
  ContextLength.eight,
  ContextLength.ten,
  ContextLength.twenty,
  ContextLength.infinite
]

let apiKeyExplainLlinks = [
  ("How to get your ChatGPT API key?", "https://www.merge.dev/blog/chatgpt-api-key"),
  ("OpenAI offical API keys WEB page", "https://platform.openai.com/api-keys")
]
let apiKeyExplain = "OpenAI provides an API for developers to integrate its GPT (Generative Pretrained Transformer) models, including ChatGPT, into their applications. The “ChatGPT API key” would refer to the unique identifier key required to authenticate and interact with the OpenAI API for using ChatGPT. Each key is unique to a user or organization and must be kept secret as it allows the holder to access the API and incur any associated costs"
