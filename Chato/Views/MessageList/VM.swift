import Combine
import SwiftData
import SwiftOpenAI
import SwiftUI
import os

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

  func ask2(text: String, contextLength: Int) {
    let isO1 = chat.option.model.contains("o1-")
    let timeout: Double = isO1 ? 120.0 : 15.0
    AppLogger.network.debug("using timeout: \(timeout), contextLength: \(contextLength)")

    var msgs: [ChatCompletionParameters.Message] = [.init(role: .user, content: .text(text))]

    var actualCL = 0
    if contextLength > 0 {
      let hist = self.modelContext.recentMessgagesEarlyOnTop(chatId: chat.persistentModelID, limit: contextLength)
      actualCL = hist.count

      for item in hist.sorted().reversed() {
        let msg: ChatCompletionParameters.Message = .init(role: item.role == .user ? .user : (item.role == .assistant ? .assistant : .system), content: .text(item.message.isMeaningful ? item.message : item.errorInfo))
        msgs.insert(msg, at: 0)
      }
    }

    chat.option.prompt?.messages.sorted().reversed().forEach {
      let msg: ChatCompletionParameters.Message = .init(role: $0.role == .assistant ? .assistant : ($0.role == .user || isO1 ? .user : .system), content: .text($0.content))
      msgs.insert(msg, at: 0)
    }

    let parameters = ChatCompletionParameters(
      messages: msgs,
      model: .custom(chat.option.model),
      frequencyPenalty: chat.option.maybeFrequencyPenalty,
      presencePenalty: chat.option.maybePresencePenalty,
      temperature: chat.option.maybeTemperature
    )

    let streamParameters = ChatCompletionParameters(
      messages: msgs,
      model: .custom(chat.option.model),
      frequencyPenalty: chat.option.maybeFrequencyPenalty,
      presencePenalty: chat.option.maybePresencePenalty,
      temperature: chat.option.maybeTemperature,
      streamOptions: ChatCompletionParameters.StreamOptions(includeUsage: true)
    )

    AppLogger.network.debug("using temperature: \(String(describing: chat.option.maybeTemperature)), presencePenalty: \(String(describing: chat.option.maybePresencePenalty)), frequencyPenalty: \(String(describing: chat.option.maybeFrequencyPenalty))")

    AppLogger.network.debug("===whole message list begins===")

    for (i, m) in msgs.enumerated() {
      AppLogger.network.debug("\(i).\(m.role): \(String(describing: m.content))")
    }

    AppLogger.network.debug("===whole message list ends===")

    var userMsg = Message(text, .user, .sending)
    userMsg.chat = chat
    userMsg.meta = .init(model: chat.option.model,
                         contextLength: contextLength,
                         actual_contextLength: actualCL,
                         promptName: chat.option.prompt?.name,
                         temperature: chat.option.temperature,
                         presencePenalty: chat.option.presencePenalty,
                         frequencyPenalty: chat.option.frequencyPenalty,
                         promptTokens: nil, completionTokens: nil, startedAt: Date.now, endedAt: nil)

    var aiMsg = Message("", .assistant, .thinking)
    aiMsg.chat = chat
    aiMsg.meta = .init(model: chat.option.model,
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
        if isO1 {
          AppLogger.network.info("not using stream")
          Task { @MainActor in
            aiMsg.meta?.startedAt = .now
          }
          let result = try await openAIService.startChat(parameters: parameters)
          Task { @MainActor in
            let content = result.choices[0].message.content ?? ""
            userMsg.onSent()
            userMsg.meta?.promptTokens = result.usage.promptTokens
            aiMsg.meta?.completionTokens = result.usage.completionTokens
            aiMsg.onEOF(text: content)
            em.messageEvent.send(.eof)
          }
        } else {
          AppLogger.network.info("using stream")
          let stream = try await openAIService.startStreamedChat(parameters: streamParameters)
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
                  if case .string(let reason) = fr {
                    AppLogger.network.debug("finished reason: \(reason)")
                    aiMsg.onEOF(text: "")
                    em.messageEvent.send(.eof)
////                    skip eof; the last chunk's 'usage' isn't nil and it has no 'choices'
//                  } else {
//                    // if reason is not stop, something may be wrong
//                    aiMsg.onError("finished reason: \(fr)", .unknown)
                  }
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
