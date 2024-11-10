import Foundation
import SwiftData

@Model
final class ChatOption {
  @Attribute(originalName: "model") var model: String
  @Attribute(originalName: "context_length") var contextLength: Int
  @Relationship(originalName: "prompt") var prompt: Prompt?
  // temperature  number or null  Optional  Defaults to 1
  // What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
  // We generally recommend altering this or top_p but not both.
  @Attribute(originalName: "temperature") var temperature: Double = 1
  // presence_penalty number or null  Optional  Defaults to 0
  // Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
  @Attribute(originalName: "presence_penalty") var presencePenalty: Double = 0
  // frequency_penalty  number or null  Optional  Defaults to 0
//  Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
  @Attribute(originalName: "frequency_penalty") var frequencyPenalty: Double = 0
  // An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.

  init(model: String = defaultGPTModel.value, contextLength: Int = 2, prompt: Prompt? = nil) {
    self.model = model
    self.contextLength = contextLength
    self.prompt = prompt
  }

  init(model: String, contextLength: Int, prompt: Prompt? = nil, temperature: Double, presencePenalty: Double, frequencyPenalty: Double) {
    self.model = model
    self.contextLength = contextLength
    self.prompt = prompt
    self.temperature = temperature
    self.presencePenalty = presencePenalty
    self.frequencyPenalty = frequencyPenalty
  }

  @Transient
  var isBestModel: Bool {
    self.model.isBestModel
  }

  @Transient
  var maybeTemperature: Double? {
    doubleEqual(self.temperature, 1.0) ? nil : self.temperature
  }

  @Transient
  var maybePresencePenalty: Double? {
    doubleEqual(self.presencePenalty, 0.0) ? nil : self.presencePenalty
  }

  @Transient
  var maybeFrequencyPenalty: Double? {
    doubleEqual(self.frequencyPenalty, 0.0) ? nil : self.frequencyPenalty
  }

  func clone() -> ChatOption {
    return ChatOption(model: self.model, contextLength: self.contextLength, prompt: self.prompt, temperature: self.temperature, presencePenalty: self.presencePenalty, frequencyPenalty: self.frequencyPenalty)
  }
}
