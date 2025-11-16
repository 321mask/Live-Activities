//
//  StepActivityAttributes.swift
//  Challenge 2
//
//  Created by Arseny Prostakov on 12/11/25.
//

import ActivityKit
import Foundation

struct StepActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // dynamic state of the activity
        var elapsedSeconds: Int
        var isPaused: Bool
        var steps: Int
        var distance: Double    // in meters
        var floorsAscended: Int
        var floorsDescended: Int
        var entryId: UUID?
    }

    // static properties
    var goalSteps: Int
    // add more static fields if you like (e.g., startDate)
}
