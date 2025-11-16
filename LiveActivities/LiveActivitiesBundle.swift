//
//  LiveActivitiesBundle.swift
//  LiveActivities
//
//  Created by Arseny Prostakov on 16/11/25.
//

import WidgetKit
import SwiftUI

@main
struct LiveActivitiesBundle: WidgetBundle {
    var body: some Widget {
        StepLiveActivityDefault()
        StepLiveActivity()
        StepLiveActivityControl()
    }
}
