import Foundation

enum ProviderType: Int32, Codable, CaseIterable {
  case openAI = 0
  case gemini = 1
  case anthropic = 2
  case stabilityAI = 3
  case deepL = 4
  case togetherAI = 5
  case replicate = 6
  case elevenLabs = 7
  case fal = 8
  case groq = 9
  case perplexity = 10
  case mistral = 11
  case eachAI = 12
  case openRouter = 13
  case deepSeek = 14
  case fireworksAI = 15
  case brave = 16
  case mock = 999

  var displayName: String {
    switch self {
    case .openAI: return "OpenAI"
    case .gemini: return "Gemini"
    case .anthropic: return "Anthropic"
    case .stabilityAI: return "Stability AI"
    case .deepL: return "DeepL"
    case .togetherAI: return "Together AI"
    case .replicate: return "Replicate"
    case .elevenLabs: return "ElevenLabs"
    case .fal: return "Fal"
    case .groq: return "Groq"
    case .perplexity: return "Perplexity"
    case .mistral: return "Mistral"
    case .eachAI: return "EachAI"
    case .openRouter: return "OpenRouter"
    case .deepSeek: return "DeepSeek"
    case .fireworksAI: return "Fireworks AI"
    case .brave: return "Brave"
    case .mock: return "Mock"
    }
  }

  var iconName: String {
    switch self {
    case .openAI: return "brain"
    case .gemini: return "sparkles"
    case .anthropic: return "square.stack.3d.up"
    case .stabilityAI: return "photo"
    case .deepL: return "translate"
    case .togetherAI: return "person.3"
    case .replicate: return "repeat"
    case .elevenLabs: return "waveform"
    case .fal: return "photo.stack"
    case .groq: return "bolt"
    case .perplexity: return "magnifyingglass"
    case .mistral: return "wind"
    case .eachAI: return "grid"
    case .openRouter: return "network"
    case .deepSeek: return "arrow.down.to.line"
    case .fireworksAI: return "sparkle"
    case .brave: return "shield"
    case .mock: return "wand.and.stars"
    }
  }
}

