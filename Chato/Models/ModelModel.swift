// Created for Chato in 2024

import Foundation
import SwiftData

@Model
final class ModelModel: Sortable {
  @Attribute(.unique, originalName: "modelId") var modelId: String
  @Attribute(originalName: "name") var name: String?
  @Attribute(originalName: "info") var info: String?
  @Attribute(originalName: "contextLength") var contextLength: Int?
  @Attribute(originalName: "pos") var pos: Int = 0

  init(modelId: String, name: String? = nil, contextLength: Int? = nil) {
    self.modelId = modelId
    if let name {
      self.name = name
    } else {
      self.name = modelNames[modelId]
    }
    self.contextLength = contextLength
    self.pos = Int(Date().timeIntervalSince1970 * 1000)
  }

}

protocol Sortable: AnyObject {
  var pos: Int { get set }
}

// Dictionary to map model IDs to their names
private let modelNames: [String: String] = [
  "babbage-002": "Babbage 002",
  "chatgpt-4o-latest": "ChatGPT-4o Latest",
  "dall-e-2": "DALL-E 2",
  "dall-e-3": "DALL-E 3",
  "davinci-002": "Davinci 002",
  "gpt-3.5-turbo": "GPT-3.5 Turbo",
  "gpt-3.5-turbo-0125": "GPT-3.5 Turbo (0125)",
  "gpt-3.5-turbo-1106": "GPT-3.5 Turbo (1106)",
  "gpt-3.5-turbo-16k": "GPT-3.5 Turbo 16k",
  "gpt-3.5-turbo-16k-0613": "GPT-3.5 Turbo 16k (0613)",
  "gpt-3.5-turbo-instruct": "GPT-3.5 Turbo Instruct",
  "gpt-3.5-turbo-instruct-0914": "GPT-3.5 Turbo Instruct (09-14)",
  "gpt-4": "GPT-4",
  "gpt-4-0125-preview": "GPT-4 Preview (01-25)",
  "gpt-4-0314": "GPT-4 (0314)",
  "gpt-4-0613": "GPT-4 (0613)",
  "gpt-4-1106-preview": "GPT-4 Preview (1106)",
  "gpt-4-32k-0314": "GPT-4 32k (0314)",
  "gpt-4-turbo": "GPT-4 Turbo",
  "gpt-4-turbo-2024-04-09": "GPT-4 Turbo (2024-04-09)",
  "gpt-4-turbo-preview": "GPT-4 Turbo Preview",
  "gpt-4o": "GPT-4o",
  "gpt-4o-2024-05-13": "GPT-4o (2024-05-13)",
  "gpt-4o-2024-08-06": "GPT-4o (2024-08-06)",
  "gpt-4o-2024-11-20": "GPT-4o (2024-11-20)",
  "gpt-4o-audio-preview": "GPT-4o Audio Preview",
  "gpt-4o-audio-preview-2024-10-01": "GPT-4o Audio Preview (2024-10-01)",
  "gpt-4o-audio-preview-2024-12-17": "GPT-4o Audio Preview (2024-12-17)",
  "gpt-4o-mini": "GPT-4o Mini",
  "gpt-4o-mini-2024-07-18": "GPT-4o Mini (2024-07-18)",
  "gpt-4o-mini-audio-preview": "GPT-4o Mini Audio Preview",
  "gpt-4o-mini-audio-preview-2024-12-17": "GPT-4o Mini Audio Preview (2024-12-17)",
  "gpt-4o-mini-realtime-preview": "GPT-4o Mini Realtime Preview",
  "gpt-4o-mini-realtime-preview-2024-12-17": "GPT-4o Mini Realtime Preview (2024-12-17)",
  "gpt-4o-realtime-preview": "GPT-4o Realtime Preview",
  "gpt-4o-realtime-preview-2024-10-01": "GPT-4o Realtime Preview (2024-10-01)",
  "gpt-4o-realtime-preview-2024-12-17": "GPT-4o Realtime Preview (2024-12-17)",
  "o1-mini": "o1 Mini",
  "o1-mini-2024-09-12": "o1 Mini (2024-09-12)",
  "o1-preview": "o1 Preview",
  "o1-preview-2024-09-12": "o1 Preview (2024-09-12)",
  "omni-moderation-2024-09-26": "Omni Moderation (2024-09-26)",
  "omni-moderation-latest": "Omni Moderation Latest",
  "text-embedding-3-large": "Text Embedding 3 Large",
  "text-embedding-3-small": "Text Embedding 3 Small",
  "text-embedding-ada-002": "Text Embedding ADA 002",
  "tts-1": "TTS 1",
  "tts-1-1106": "TTS 1 (v1106)",
  "tts-1-hd": "TTS 1 HD",
  "tts-1-hd-1106": "TTS 1 HD (v1106)",
  "whisper-1": "Whisper 1",
]
