//
//  AppIntent.swift
//  ClassWidget
//
//  Created by Suman Muppavarapu on 9/15/24.
//

import WidgetKit
import AppIntents

@available(iOS 17.0, *)
struct ConfigurationAppIntent: WidgetConfigurationIntent, Sendable {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "Configure your class widget." }

    @Parameter(title: "Mascot Name", default: "😃")
    var favoriteEmoji: String
    
    // Add this initializer
    init() {
        self.favoriteEmoji = "😃"
    }
    
    init(favoriteEmoji: String) {
        self.favoriteEmoji = favoriteEmoji
    }
}
