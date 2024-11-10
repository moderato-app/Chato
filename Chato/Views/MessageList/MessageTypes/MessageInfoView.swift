import SwiftUI

import Haptico
import SwiftData
import SwiftUI

struct MessageInfoView: View {
  @Environment(\.dismiss) private var dismiss
  let message: Message

  var body: some View {
      Form {
        MessageMetaView(message: message)
      }
  }
}
