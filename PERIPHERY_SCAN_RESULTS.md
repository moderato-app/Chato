# Periphery 扫描结果报告

生成时间: 2025-01-27

## 扫描统计

- **总警告数**: 100+
- **扫描工具**: Periphery
- **项目**: Chato

## ✅ 已删除的代码

### 第一阶段删除（已验证构建成功）

1. **EventManager.swift**
   - ✅ 删除 `exampleEvent` 属性

2. **Extensions/Haptics.swift**
   - ✅ 删除 `successFeedback(_:)` 函数

3. **Extensions/Pasteboard.swift**
   - ✅ 删除整个文件（`copy(_:)` 函数未使用）

4. **Extensions/String.swift**
   - ✅ 删除 `containsEmoji` 属性
   - ✅ 删除 `isEmoji` 扩展（Unicode.Scalar.Properties）

5. **Service/AudioService.swift**
   - ✅ 删除整个文件（完全未使用）

6. **Service/Highlight.swift**
   - ✅ 删除整个文件（`convertToText(_:)` 函数未使用）

7. **Util/Cache.swift**
   - ✅ 删除整个文件（`ChatRowCache` 和 `ChatRowCacheItem` 未使用）

8. **Views/MessageList/MessageTypes/MessageInfoView.swift**
   - ✅ 删除整个文件（未使用的 View）

9. **Models/SQL.swift**
   - ✅ 删除 `updateModels(models:)` 函数
   - ✅ 删除 `getChat(chatId:)` 函数

10. **State/State.swift**
    - ✅ 删除 `shared` 属性

11. **Util/Util.swift**
    - ✅ 删除 `EnvType` 枚举
    - ✅ 删除 `currentEnvType` 变量

**构建状态**: ✅ 构建成功，无错误

### 第二阶段删除（已验证构建成功）

12. **Extensions/SwiftUI.swift**
    - ✅ 删除 `SwitchablePickerStyle` ViewModifier
    - ✅ 删除 `apply(transform:)` 函数
    - ✅ 删除 `SwitchableScrollView` ViewModifier
    - ✅ 删除 `KeyboardResponder` 类
    - ✅ 删除 `SafeAreaInsetsKey` 和 `safeAreaInsets` 环境值
    - ✅ 删除 `swiftUiInsets` 扩展
    - ✅ 删除 `ViewOffsetKey` PreferenceKey
    - ✅ 删除 `YRange` 结构体（yMin, yMax 未使用）
    - ✅ 删除 `ViewPoint` PreferenceKey
    - ✅ 删除 `heightPercent(_:)` 函数
    - ✅ 删除 `allDetents` 属性（保留 mediumDetents 和 largeDetents）
    - ✅ 删除 `Color.random` 属性
    - ✅ 删除 `printChagesWhenDebug()` 函数
    - ✅ 删除 `RectDetector` 和 `detectRect(_:)`
    - ✅ 删除 `SizeDetector` 和 `detectSize(_:)`
    - ✅ 删除 `SelectableModifier` 和 `selectable()` 函数
    - ⚠️ 保留 `RemoveFocusOnTapModifier`（在 MessageList 中使用）

13. **Models/Message.swift**
    - ✅ 删除 `senderName` 属性

14. **Models/ModelEntity.swift**
    - ✅ 删除 `displayName` 属性

15. **Models/ModelModel.swift**
    - ✅ 删除 `sortOrder` 属性
    - ✅ 删除 `provider` 计算属性
    - ✅ 删除 `reIndex()` 扩展函数
    - ✅ 删除 `Sortable` 协议的 `sortOrder` 要求（保留 `pos`）

16. **Models/Provider.swift**
    - ✅ 删除 `favoritedModels` 计算属性
    - ✅ 删除 `nonFavoritedModels` 计算属性

17. **Views/Widget/WheelPicker.swift**
    - ✅ 删除 `valueToIndex(_: Int)` 重载函数
    - ⚠️ 保留 `defaultValue`（在 init 中用于计算 defaultIndex）

**构建状态**: ✅ 构建成功，无错误

## 未使用代码分类

### 🔴 高优先级 - 可以安全删除

#### 1. EventManager.swift
- `exampleEvent` - 未使用的属性

#### 2. Extensions/Haptics.swift
- `successFeedback(_:)` - 未使用的函数

#### 3. Extensions/Pasteboard.swift
- `copy(_:)` - 未使用的函数

#### 4. Extensions/String.swift
- `containsEmoji` - 未使用的属性
- `isEmoji` - 未使用的属性

#### 5. Extensions/SwiftUI.swift
大量未使用的代码：
- `SwitchablePickerStyle` - 未使用的结构体
- `apply(transform:)` - 未使用的函数
- `SwitchableScrollView` - 未使用的结构体
- `RemoveFocusOnTapModifier` - 声明为 public 但未在外部使用
- `KeyboardResponder` - 未使用的类
- `SafeAreaInsetsKey` - 未使用的结构体
- `safeAreaInsets` - 未使用的属性
- `ViewOffsetKey` - 未使用的结构体
- `yMin`, `yMax` - 赋值但未使用
- `ViewPoint` - 未使用的结构体
- `heightPercent(_:)` - 未使用的函数
- `allDetents` - 未使用的属性
- `random` - 未使用的属性
- `printChagesWhenDebug()` - 未使用的函数
- `RectDetector` - 未使用的结构体
- `detectRect(_:)` - 未使用的函数
- `SizeDetector` - 未使用的结构体
- `detectSize(_:)` - 未使用的函数
- `SelectableModifier` - 未使用的结构体
- `selectable()` - 未使用的函数

#### 6. Models/Data/ChatGPT.swift
- `apiKeyExplainLlinks` - 未使用的属性
- `apiKeyExplain` - 未使用的属性

#### 7. Models/Data/PromptSample.swift
- `languageCodes` - 赋值但未使用

#### 8. Models/Message.swift
- `senderName` - 未使用的属性

#### 9. Models/ModelEntity.swift
- `displayName` - 未使用的属性
- `favorited` - 未使用的属性

#### 10. Models/ModelModel.swift
- `sortOrder` - 未使用的属性
- `resolvedName` - 未使用的属性
- `provider` - 未使用的属性
- `reIndex()` - 未使用的函数
- `Sortable` 协议 - 冗余（从未作为存在类型使用）

#### 11. Models/Provider.swift
- `favoritedModels` - 未使用的属性
- `nonFavoritedModels` - 未使用的属性

#### 12. Models/SQL.swift
- `updateModels(models:)` - 未使用的函数
- `getChat(chatId:)` - 未使用的函数

#### 13. Models/Setting.swift
- `computedColorScheme` - 未使用的属性

#### 14. Service/AIClient.swift
大量未使用的代码：
- `fetchModels()` - 多个未使用的函数
- `models(endpoint:apiKey:timeout:)` - 未使用的函数
- 多个未使用的属性：`created`, `architecture`, `pricing`, `topProvider`, `perRequestLimits`, `modality`, `tokenizer`, `instructType`, `prompt`, `completion`, `image`, `request`, `contextLength`, `maxCompletionTokens`, `isModerated`

#### 15. Service/AppLogger.swift
- `performance` - 未使用的属性
- `AuditEntry` - 未使用的结构体
- `iso8601Formatter` - 未使用的属性
- `jsonString(from:)` - 未使用的函数
- `logAudit(_:)` - 未使用的函数
- `PerformanceSession` - 未使用的类
- `startPerformanceTracking(_:)` - 未使用的函数
- `logValidationFailure(field:reason:value:)` - 未使用的函数
- `logUIEvent(component:action:details:)` - 未使用的函数
- `AuditEntry` 扩展 - 未使用

#### 16. Service/AudioService.swift
- `AudioService` - 未使用的结构体

#### 17. Service/Highlight.swift
- `convertToText(_:)` - 未使用的函数

#### 18. Service/ModelFetcherFactory.swift
- `providerType` - 赋值但未使用

#### 19. State/State.swift
- `shared` - 未使用的属性

#### 20. StoreKit.swift
- `RenewalInfo` - 未使用的类型别名
- `RenewalState` - 未使用的类型别名
- `subscriptionGroupStatus` - 未使用的属性
- `coffeeCount` - 声明为 public 但未在外部使用
- `purchase(_:)` - 多个未使用的函数
- `StoreError` - 声明为 public 但未在外部使用

#### 21. Theme+Effect/Icons.swift
- `SendIconLight` - 未使用的结构体
- `SendIcon` - 未使用的结构体
- `colorScheme` - 未使用的属性

#### 22. Theme+Effect/Ripple.swift
- `PushEffect` - 未使用的结构体

#### 23. Theme+Effect/Theme.swift
- `NavAppearanceModifier` - 未使用的结构体

#### 24. Tips/
- `AdvancedOptionDoubleTapTip.instance` - 声明为 public 但未在外部使用
- `SendButtonTip.instance` - 声明为 public 但未在外部使用

#### 25. Util/Cache.swift
- `ChatRowCacheItem` - 未使用的结构体
- `ChatRowCache` - 未使用的类

#### 26. Util/Util.swift
- `EnvType` - 未使用的枚举
- `currentEnvType` - 未使用的属性

#### 27. Views/MessageList/MessageTypes/MessageInfoView.swift
- `MessageInfoView` - 未使用的结构体

#### 28. Views/Widget/WheelPicker.swift
- `defaultValue` - 赋值但未使用
- `valueToIndex(_:)` - 未使用的函数（重载版本）

### ⚠️ 中优先级 - 需要确认

这些可能是误报或将来会使用的代码：

#### 1. Views 中的未使用属性
很多 View 中有未使用的 `@Environment` 和 `@State` 属性，这些可能是：
- 预留的功能
- 调试代码
- 未来会使用的代码

例如：
- `ChatListView.pref`
- `ChatListView.removeChat(_:)`
- `NewChatView.detent`
- `ChatAdvancedOptionView.pref`
- `ChatOptionView.pref`, `modelContext`, `pickerNavi`
- `ModelSelectionView.modelContext`
- `ContentView.colorScheme`
- `InputAreaView.pref`, `contextLength`
- `ErrorView.pref`
- `StatusView.colorScheme`
- `ThinkingView.animationInterval`
- `VM.hideKeyboard()`
- `PromptCreateView.presentationMode`
- `PromptEditorView.presentationMode`, `dismiss`, `pref`
- `PromptListView.isCreatePromptPresented`, `pref`, `remove(_:)`
- `ProviderDetailView.dismiss`
- `SettingView+Purchase.buy(product:)`

#### 2. Service/Deps/APIClientKey.swift
- `timeout` 参数未使用 - 可能是预留的功能

#### 3. Other.swift
- `companyEmail` - 可能用于未来功能

## 建议的清理策略

### 第一阶段：安全删除（高优先级）
1. 删除完全未使用的结构体、类、函数
2. 删除未使用的属性（确认不是通过反射调用）
3. 清理冗余的协议和扩展

### 第二阶段：谨慎处理（中优先级）
1. 检查 Views 中的未使用属性，确认是否为预留功能
2. 检查 Service 层的未使用代码，确认是否为 API 预留
3. 检查 StoreKit 相关代码，确认是否为内购功能预留

### 第三阶段：代码审查
1. 手动审查每个警告
2. 确认没有通过字符串或反射动态调用的代码
3. 确认没有在测试中使用的代码

## 注意事项

1. **动态调用**: 某些代码可能通过字符串或反射动态调用，Periphery 无法检测
2. **测试代码**: 某些代码可能只在测试中使用，需要检查测试文件
3. **未来功能**: 某些代码可能是为未来功能预留的
4. **Public API**: 某些 public 声明可能是为了外部使用，需要确认

## 下一步行动

1. 先处理高优先级的未使用代码
2. 构建验证确保没有破坏功能
3. 逐步处理中优先级的代码
4. 定期运行 Periphery 扫描保持代码整洁

