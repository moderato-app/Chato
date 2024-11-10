import Foundation
import SwiftData

@Model
final class MessageMeta {
  @Attribute(originalName: "model") var model: String = ""
  @Attribute(originalName: "context_length") var contextLength: Int = 0
  @Attribute(originalName: "actual_context_length") var actual_contextLength: Int = 0
  @Attribute(originalName: "promptName") var promptName: String? = nil
  @Attribute(originalName: "temperature") var temperature: Double = 1
  @Attribute(originalName: "presence_penalty") var presencePenalty: Double = 0
  @Attribute(originalName: "frequency_penalty") var frequencyPenalty: Double = 0
  @Attribute(originalName: "prompt_tokens") var promptTokens: Int? = nil
  @Attribute(originalName: "completion_tokens") var completionTokens: Int? = nil
  @Attribute(originalName: "startedAt") var startedAt: Date? = nil
  @Attribute(originalName: "endedAt") var endedAt: Date? = nil

  init(model: String, contextLength: Int, actual_contextLength: Int, promptName: String?, temperature: Double,
       presencePenalty: Double, frequencyPenalty: Double, promptTokens: Int?,completionTokens: Int?,
       startedAt: Date?, endedAt: Date? )
  {
    self.model = model
    self.contextLength = contextLength
    self.actual_contextLength = actual_contextLength
    self.promptName = promptName
    self.temperature = temperature
    self.presencePenalty = presencePenalty
    self.frequencyPenalty = frequencyPenalty
    self.promptTokens = promptTokens
    self.completionTokens = completionTokens
    self.startedAt = startedAt
    self.endedAt = endedAt
  }

  func clone() -> MessageMeta {
    return .init(
      model: model,
      contextLength: contextLength,
      actual_contextLength: actual_contextLength,
      promptName: promptName,
      temperature: temperature,
      presencePenalty: presencePenalty,
      frequencyPenalty: frequencyPenalty,
      promptTokens: promptTokens,
      completionTokens: completionTokens,
      startedAt: startedAt,
      endedAt: endedAt
    )
  }
}
