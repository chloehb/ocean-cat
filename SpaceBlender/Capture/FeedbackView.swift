/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
SwiftUI view that displays the feedback messages for scanning.
*/
// reference: third-party object capture tool: https://developer.apple.com/augmented-reality/object-capture/

import Foundation
import RealityKit
import SwiftUI

struct FeedbackView: View {
    @ObservedObject var messageList: TimedMessageList

    var body: some View {
        VStack {
            if let activeMessage = messageList.activeMessage {
                Text("\(activeMessage.message)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .environment(\.colorScheme, .dark)
                    .transition(.opacity)
            }
        }
    }
}
