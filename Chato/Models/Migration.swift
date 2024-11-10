import Foundation
import SwiftData

func migrate(_ modelContext: ModelContext) throws {
  // TODO: It's safe to delete all asm and migratePref() at 01/01/2025
  let asms = try modelContext.fetch(FetchDescriptor<AppStateModel>())
  if let asm = asms.first {
    migratePref(asm: asm)
    modelContext.delete(asm)
  }

  let res = try modelContext.fetch(FetchDescriptor<Functionality>()).first
  if let fun = res {
    Pref.shared.haptics = fun.haptics
    Pref.shared.doubleTapAction = DoubleTapAction(rawValue: fun.doubleTapAction.rawValue) ?? .reuse
    modelContext.delete(fun)
  }

  try? modelContext.save()

  try? fillData(modelContext)
}

private func fillData(_ modelContext: ModelContext) throws {
  if !Pref.shared.fillDataRecordGreeting {
    modelContext.insert(ChatSample.greetings)
    for m in ChatSample.greetings.messages {
      m.chat = ChatSample.greetings
    }
    Pref.shared.fillDataRecordGreeting = true
  }

  if !Pref.shared.fillDataRecordPrompts {
    try fillPrompts(modelContext,save: false)
    Pref.shared.fillDataRecordPrompts = true
  }

  try? modelContext.save()
}

func fillPrompts(_ modelContext: ModelContext, save: Bool) throws {
  let descriptor = FetchDescriptor<Prompt>(
    predicate: #Predicate { !$0.preset }
  )
  let count = (try? modelContext.fetchCount(descriptor)) ?? 0

  let english = PromptSample.english()

  english.prompts.reIndex()

  for p in english.prompts {
    p.order += count
    modelContext.insert(p)
    p.messages.reIndex()
  }

  modelContext.insert(PromptSample.userDefault)

  if save{
    try? modelContext.save()
  }
}

func addPreviewData(_ modelContext: ModelContext) throws {
  for c in ChatSample.previewChats {
    modelContext.insert(c)
  }
  try? modelContext.save()
}

func migratePref(asm: AppStateModel) {
  print("migrating pref")
  let pref = Pref.shared

  pref.colorScheme = Pref.AppColorScheme(rawValue: asm.colorScheme.rawValue) ?? .system

  pref.gptApiKey = asm.chatGPTConfig.apiKey
  pref.gptProxyHost = asm.chatGPTConfig.proxyHost
  pref.gptUseProxy = asm.chatGPTConfig.userProxy

  if let opt = asm.lastUsedOption {
    pref.lastUsedModel = opt.model
    pref.lastUsedContextLength = opt.contextLength
  }

  if let dr = asm.dataRecord {
    pref.fillDataRecordGreeting = dr.greeting
    pref.fillDataRecordPrompts = dr.prompts
  }
}
