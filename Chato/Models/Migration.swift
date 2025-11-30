import Foundation
import os
import SwiftData

func migrate(_ modelContext: ModelContext) throws {
  try? fillData(modelContext)
  try? modelContext.save()
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
