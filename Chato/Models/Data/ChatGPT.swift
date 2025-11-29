import Foundation

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
      return "\(length)"
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
  ("OpenAI’s official API keys webpage", "https://platform.openai.com/api-keys")
]

let apiKeyExplain = "OpenAI offers an API that lets developers add GPT models, like ChatGPT, to their apps. A ChatGPT API key is a unique code you need to access and use the OpenAI API. Each key is tied to a specific user or organization and must be kept private because it grants access to the API and any associated costs."
