import Combine
import OpenAI
import SwiftData
import SwiftUI

extension InputAreaView {
  static let whiteSpaces: [Character] = ["\n", " ", "\t"]

  func setupDebounce() {
    cancellable?.cancel()
    cancellable = subject
      .debounce(for: .seconds(1), scheduler: RunLoop.main)
      .sink { value in
        print("chat.input = value")
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
    contextLength = chat.option.contextLength
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
        print("inputText cleared")
      } catch {
        print("delayClearInput: \(error.localizedDescription)")
      }
    }
  }

  func ask(text: String, useContext: Bool = true) {
    var openAI: ChatGPTContext
    let isO1 = chat.option.model.contains("o1-")
    let timeout: Double = isO1 ? 120.0 : 15.0
    print("using timeout: \(timeout)")
    if pref.gptUseProxy, !pref.gptProxyHost.isEmpty {
      openAI = ChatGPTContext(apiKey: pref.gptApiKey, proxyHost: pref.gptProxyHost, timeout: timeout)
    } else {
      openAI = ChatGPTContext(apiKey: pref.gptApiKey, timeout: timeout)
    }
    
    let q = ChatQuery(model: chat.option.model, messages: [.init(role: .user, content: text)])
    var macpaw = q.messages
    
    if useContext, chat.option.contextLength > 0 {
      let hist = self.modelContext.recentMessgagesEarlyOnTop(chatId: chat.persistentModelID, limit: chat.option.contextLength)
      
      for item in hist.sorted().reversed() {
        macpaw.insert(.init(role: item.role == .user ? .user : (item.role == .assistant ? .assistant : .system), content: item.message.isMeaningful ? item.message : item.errorInfo), at: 0)
      }
    }
    
    chat.option.prompt?.messages.sorted().reversed().forEach {
      macpaw.insert(.init(role: $0.role == .assistant ? .assistant : ($0.role == .user || isO1 ? .user : .system), content: $0.content), at: 0)
    }
    
    newChatCallback()
    
    let query = ChatQuery(model: chat.option.model, messages: macpaw)
    
    print("===whole message list begins===")
    
    for (i, m) in query.messages.enumerated() {
      print("\(i).\(m.role): \(m.content ?? "")")
    }
    
    print("===whole message list ends===")
    
    var userMsg = Message(text, .user, .sending)
    userMsg.chat = chat
    
    var aiMsg = Message("", .assistant, .thinking)
    aiMsg.chat = chat
    
    do {
      // it seems model data can only stay consistent when all the ops happen in a non-breakable main actor
      try modelContext.save()
      userMsg = modelContext.getMessage(messageId: userMsg.id).unsafelyUnwrapped
      aiMsg = modelContext.getMessage(messageId: aiMsg.id).unsafelyUnwrapped
    } catch {
      print("Error: Failed to save messages into model container: \(error.localizedDescription)")
      return
    }
    
    Task.detached {
      await sleepFor(0.1)
      Task { @MainActor in
        em.messageEvent.send(.new)
      }
    }
    
    if isO1 {
      print("using stream: false")
      openAI.client.chats(query: query) { res in
        DispatchQueue.main.async {
          if userMsg.status == .sending {
            userMsg.onSent()
          }
          switch res {
          case .success(let result):
            let content = result.choices[0].message.content ?? ""
            aiMsg.onEOF(text: content)
            em.messageEvent.send(.eof)
          case .failure(let error):
            if !error.localizedDescription.contains("The data couldn’t be read because it isn’t in the correct format") {
              // macpaw's lib has problem reading message
              let info = error.localizedDescription.lowercased()
              if info.contains("api key") || info.contains("apikey") {
                aiMsg.onError(error.localizedDescription, .apiKey)
              } else {
                aiMsg.onError(error.localizedDescription, .unknown)
              }
              print("res error: \(info)")
              em.messageEvent.send(.err)
            }
          }
        }
      }
    } else {
      print("using stream: true")
      openAI.client.chatsStream(query: query) { partialResult in
        DispatchQueue.main.async {
          if userMsg.status == .sending {
            userMsg.onSent()
          }
          
          switch partialResult {
          case .success(let result):
            let content = result.choices[0].delta.content ?? ""
            if let _ = result.choices[0].finishReason {
              aiMsg.onEOF(text: content)
            } else {
              aiMsg.onTyping(text: content)
            }
          case .failure(let error):
            if !error.localizedDescription.contains("The data couldn’t be read because it isn’t in the correct format") {
              // macpaw's lib has problem reading message
              let info = error.localizedDescription.lowercased()
              if info.contains("api key") || info.contains("apikey") {
                aiMsg.onError(error.localizedDescription, .apiKey)
              } else {
                aiMsg.onError(error.localizedDescription, .unknown)
              }
              print("partialResult error: \(info)")
              em.messageEvent.send(.err)
            }
          }
        }
      } completion: { error in
        DispatchQueue.main.async {
          if let error = error {
            let info = error.localizedDescription
            if info.contains("The Internet connection appears to be offline") {
              aiMsg.onError(error.localizedDescription, .network)
            } else {
              aiMsg.onError(error.localizedDescription, .unknown)
            }
            print("completion error: \(info)")
            em.messageEvent.send(.err)
          } else {
            print("openAI.client.chatsStream done")
            em.messageEvent.send(.eof)
          }
        }
      }
    }
  }
}
