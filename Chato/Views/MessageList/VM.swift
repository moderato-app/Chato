import AIProxy
import Combine
import os
import SwiftData
import SwiftUI

extension InputAreaView {
  static let whiteSpaces: [Character] = ["\n", " ", "\t"]

  func setupDebounce() {
    cancellable?.cancel()
    cancellable = subject
      .debounce(for: .seconds(1), scheduler: RunLoop.main)
      .sink { value in
        AppLogger.ui.debug("chat.input = value")
        chat.input = value
      }
  }

  func destroyDebounce() {
    cancellable?.cancel()
    chat.input = inputText
  }

  func debounceText(newText: String) {
    DispatchQueue.main.async {
      subject.send(newText)
    }
  }

  func reloadInputArea() {
    inputText = chat.input
  }

  func reuseOrCancel(text: String) {
    if text.isEmpty {
      return
    }

    if inputText.hasSuffix(text + " ") {
      withAnimation(.bouncy) {
        inputText.removeLast((text + " ").count)
      }
      return
    }

    if inputText.hasSuffix(text) {
      withAnimation(.bouncy) {
        inputText.removeLast(text.count)
      }
      return
    }

    if !inputText.isEmpty, !Self.whiteSpaces.contains(inputText.last!) {
      inputText += " "
    }

    if text.count < 300 {
      withAnimation(.bouncy) {
        inputText += text
      }
    } else {
      inputText += text
    }
  }

  func hideKeyboard() {
    #if os(iOS)
      UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    #endif
  }

  func delayClearInput() async {
    Task { @MainActor in
      do {
        try await Task.sleep(nanoseconds: 100_000_000)
        inputText = ""
        AppLogger.ui.debug("inputText cleared")
      } catch {
        AppLogger.error.error("delayClearInput: \(error.localizedDescription)")
      }
    }
  }

  func ask2(text: String, contextLength: Int, model: ModelEntity) {
    var msgs: [OpenAIChatCompletionRequestBody.Message] = [.user(content: .text(text))]

    var actualCL = 0
    if contextLength > 0 {
      let hist = self.modelContext.recentMessgagesEarlyOnTop(chatId: chat.persistentModelID, limit: contextLength)
      actualCL = hist.count

      for item in hist.sorted().reversed() {
        let msg: OpenAIChatCompletionRequestBody.Message
        switch item.role {
        case .user:
          msg = .user(content: .text(item.message.isMeaningful ? item.message : item.errorInfo))
        case .assistant:
          msg = .assistant(content: .text(item.message.isMeaningful ? item.message : item.errorInfo))
        default:
          msg = .system(content: .text(item.message.isMeaningful ? item.message : item.errorInfo))
        }
        msgs.insert(msg, at: 0)
      }
    }

    chat.option.prompt?.messages.sorted().reversed().forEach {
      let msg: OpenAIChatCompletionRequestBody.Message
      if $0.role == .assistant {
        msg = .assistant(content: .text($0.content))
      } else if $0.role == .user {
        msg = .user(content: .text($0.content))
      } else {
        msg = .system(content: .text($0.content))
      }
      msgs.insert(msg, at: 0)
    }

    let streamParameters = OpenAIChatCompletionRequestBody(
      model: model.modelId,
      messages: msgs,
      frequencyPenalty: chat.option.maybeFrequencyPenalty,
      presencePenalty: chat.option.maybePresencePenalty,
      stream: true,
      temperature: chat.option.maybeTemperature
    )

    AppLogger.network.debug("using temperature: \(String(describing: chat.option.maybeTemperature)), presencePenalty: \(String(describing: chat.option.maybePresencePenalty)), frequencyPenalty: \(String(describing: chat.option.maybeFrequencyPenalty))")

    AppLogger.network.debug("===whole message list begins===")

    for (i, m) in msgs.enumerated() {
      let roleStr: String
      switch m {
      case .user: roleStr = "user"
      case .assistant: roleStr = "assistant"
      case .system: roleStr = "system"
      case .developer: roleStr = "developer"
      case .tool: roleStr = "tool"
      }
      AppLogger.network.debug("\(i).\(roleStr): \(String(describing: m))")
    }

    AppLogger.network.debug("===whole message list ends===")

    var userMsg = Message(text, .user, .sending)
    userMsg.chat = chat
    userMsg.meta = .init(model: model.modelId,
                         contextLength: contextLength,
                         actual_contextLength: actualCL,
                         promptName: chat.option.prompt?.name,
                         temperature: chat.option.temperature,
                         presencePenalty: chat.option.presencePenalty,
                         frequencyPenalty: chat.option.frequencyPenalty,
                         promptTokens: nil, completionTokens: nil, startedAt: Date.now, endedAt: nil)

    var aiMsg = Message("", .assistant, .thinking)
    aiMsg.chat = chat
    aiMsg.meta = .init(model: model.modelId,
                       contextLength: contextLength,
                       actual_contextLength: actualCL,
                       promptName: chat.option.prompt?.name,
                       temperature: chat.option.temperature,
                       presencePenalty: chat.option.presencePenalty,
                       frequencyPenalty: chat.option.frequencyPenalty,
                       promptTokens: nil, completionTokens: nil, startedAt: nil, endedAt: nil)

    do {
      // it seems model data can only stay consistent when all the ops happen in a non-breakable main actor
      try modelContext.save()
      userMsg = modelContext.getMessage(messageId: userMsg.id).unsafelyUnwrapped
      aiMsg = modelContext.getMessage(messageId: aiMsg.id).unsafelyUnwrapped
    } catch {
      AppLogger.logError(.from(
        error: error,
        operation: "Save message",
        component: "MessageListVM",
        userMessage: "Failed to save, please try again"
      ))
      return
    }

    Task.detached {
      Task { @MainActor in
        em.messageEvent.send(.new)
      }
    }

    Task.detached {
      do {
        AppLogger.network.info("using stream")
        let stream = try await openAIService.streamingChatCompletionRequest(body: streamParameters, secondsToWait: 60)
        for try await chunk in stream {
          Task { @MainActor in
            if aiMsg.meta?.startedAt == nil {
              aiMsg.meta?.startedAt = .now
            }
            if userMsg.status == .sending {
              userMsg.onSent()
            }

            if let choice = chunk.choices.first {
              let text = choice.delta.content ?? "\nchoice has no content\n"
              if let fr = choice.finishReason {
                AppLogger.network.debug("finished reason: \(fr)")
                aiMsg.onEOF(text: "")
                em.messageEvent.send(.eof)
              } else {
                aiMsg.onTyping(text: text)
              }
            } else {
              if let usage = chunk.usage {
                userMsg.meta?.promptTokens = usage.promptTokens
                aiMsg.meta?.completionTokens = usage.completionTokens
                aiMsg.onEOF(text: "")
                em.messageEvent.send(.eof)
              } else {
                AppLogger.network.debug("no text in chunk, chunk: \(String(describing: chunk))")
              }
            }
          }
        }
      } catch {
        Task { @MainActor in
          let info = "\(error)"
          if info.lowercased().contains("api key") || info.lowercased().contains("apikey") {
            aiMsg.onError(info, .apiKey)
          } else {
            aiMsg.onError(info, .unknown)
          }
          userMsg.onSent()
          AppLogger.error.error("partialResult error: \(error)")
          em.messageEvent.send(.err)
        }
      }
    }
  }
}
