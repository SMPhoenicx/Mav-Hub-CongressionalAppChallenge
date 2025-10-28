//
//  ScheduleLiveActivity.swift
//  Schedule
//
//  Created by Jack Vu on 8/29/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ScheduleAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ScheduleLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ScheduleAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ScheduleAttributes {
    fileprivate static var preview: ScheduleAttributes {
        ScheduleAttributes(name: "World")
    }
}

extension ScheduleAttributes.ContentState {
    fileprivate static var smiley: ScheduleAttributes.ContentState {
        ScheduleAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ScheduleAttributes.ContentState {
         ScheduleAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ScheduleAttributes.preview) {
   ScheduleLiveActivity()
} contentStates: {
    ScheduleAttributes.ContentState.smiley
    ScheduleAttributes.ContentState.starEyes
}
