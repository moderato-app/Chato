import Foundation
import os
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

  try? migrateToProviderModel(modelContext)
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
    try fillPrompts(modelContext, save: false)
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

  if save {
    try? modelContext.save()
  }
}

func addPreviewData(_ modelContext: ModelContext) throws {
  for c in ChatSample.previewChats {
    modelContext.insert(c)
  }
  for c in ModelModel.samples {
    modelContext.insert(c)
  }
  AppLogger.data.info("add preview data: \(ChatSample.previewChats.count) chats, \(ModelModel.samples.count) models")
  try? modelContext.save()
}

func migratePref(asm: AppStateModel) {
  AppLogger.data.info("migrating pref")
  let pref = Pref.shared

  pref.colorScheme = Pref.AppColorScheme(rawValue: asm.colorScheme.rawValue) ?? .system

  pref.gptApiKey = asm.chatGPTConfig.apiKey
  pref.gptEndpoint = "https://" + asm.chatGPTConfig.proxyHost
  pref.gptEnableEndpoint = asm.chatGPTConfig.userProxy

  if let opt = asm.lastUsedOption {
    pref.lastUsedContextLength = opt.contextLength
  }

  if let dr = asm.dataRecord {
    pref.fillDataRecordGreeting = dr.greeting
    pref.fillDataRecordPrompts = dr.prompts
  }
}

func migrateToProviderModel(_ modelContext: ModelContext) throws {
  let pref = Pref.shared

  guard !pref.migratedToProviderModel else {
    AppLogger.data.info("Already migrated to Provider model")
    return
  }

  AppLogger.data.info("Starting migration to Provider model")

  let existingModels = try modelContext.fetch(FetchDescriptor<ModelModel>())

  guard !existingModels.isEmpty else {
    AppLogger.data.info("No existing models to migrate")
    pref.migratedToProviderModel = true
    return
  }

  let existingProviders = try modelContext.fetch(FetchDescriptor<Provider>())
  let existingAIModels = try modelContext.fetch(FetchDescriptor<ModelEntity>())

  if !existingProviders.isEmpty || !existingAIModels.isEmpty {
    AppLogger.data.info("Provider/AIModel data already exists, skipping migration")
    pref.migratedToProviderModel = true
    return
  }

  let openAIProvider = Provider(
    type: .openAI,
    alias: "",
    apiKey: pref.gptApiKey,
    endpoint: pref.gptEnableEndpoint ? pref.gptEndpoint : "",
    enabled: true
  )
  modelContext.insert(openAIProvider)

  for oldModel in existingModels {
    let newModel = ModelEntity(
      provider: openAIProvider,
      modelId: oldModel.modelId,
      modelName: oldModel.name,
      contextLength: oldModel.contextLength,
      favorited: false,
      isCustom: false,
    )
    modelContext.insert(newModel)
  }

  try modelContext.save()

  pref.migratedToProviderModel = true

  AppLogger.data.info("Successfully migrated \(existingModels.count) models to Provider model")
}
