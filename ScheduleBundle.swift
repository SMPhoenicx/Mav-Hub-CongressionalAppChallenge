//
//  ScheduleBundle.swift
//  Schedule
//
//  Created by Jack Vu on 8/29/24.
//

import WidgetKit
import SwiftUI

@main
struct ScheduleBundle: WidgetBundle {
    var body: some Widget {
        Schedule()
        ScheduleLiveActivity()
    }
}
