//
//  StepLiveActivity.swift
//  Challenge 2
//
//  Created by Arseny Prostakov on 12/11/25.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct StepLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StepActivityAttributes.self) { context in
            // Lock Screen UI
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    ZStack(alignment: .center) {
                        ProgressView(
                            value: Double(context.state.steps),
                            total: Double(context.attributes.goalSteps)
                        )
                        .progressViewStyle(.circular)
                        .tint(.indigo)
                        
                        Text(
                            "\(progressPercentage(steps: context.state.steps, goal: context.attributes.goalSteps))%"
                        )
                        .foregroundStyle(.indigo)
                        .font(.system(size: 34, weight: .bold))
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .center, spacing: 0) {
                        Text("TOTAL TIME")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(formatTime(context.state.elapsedSeconds))
                            .font(.title)
                            .bold()
                    }
                    .padding(.top, 18)
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("STEP COUNT")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("\(context.state.steps)")
                            .font(.title)
                            .bold()
                    }
                }
            } compactLeading: {
                // Compact Leading - Circular Progress
                ZStack(alignment: .center) {
                    ProgressView(
                        value: Double(context.state.steps),
                        total: Double(context.attributes.goalSteps)
                    )
                    .progressViewStyle(.circular)
                    .tint(.indigo)
                    .scaleEffect(1.8)

                    Image(systemName: "shoe")
                    .foregroundStyle(.indigo)
                    .font(.system(size: 11, weight: .bold))
                }.padding(4)
            } compactTrailing: {
                // Compact Trailing - Time
                Text(formatTime(context.state.elapsedSeconds))
                    .font(.system(size: 14, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(.indigo)
            } minimal: {
                // Minimal - Just the percentage circle
                ZStack(alignment: .center) {
                    ProgressView(
                        value: Double(context.state.steps),
                        total: Double(context.attributes.goalSteps)
                    )
                    .progressViewStyle(.circular)
                    .tint(.indigo)
                    .scaleEffect(1.8)

                    Image(systemName: "shoe")
                    .foregroundStyle(.indigo)
                    .font(.system(size: 11, weight: .bold))
                }.padding(4)
            }
        }
    }

    private func progressPercentage(steps: Int, goal: Int) -> Int {
        guard goal > 0 else { return 0 }
        return min(Int((Double(steps) / Double(goal)) * 100), 100)
    }

    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}

#Preview(
    "Dynamic Island Compact",
    as: .dynamicIsland(.compact),
    using: StepActivityAttributes(goalSteps: 10000)
) {
    StepLiveActivity()
} contentStates: {
    StepActivityAttributes.ContentState(
        elapsedSeconds: 39,
        isPaused: false,
        steps: 0,
        distance: 0,
        floorsAscended: 0,
        floorsDescended: 0
    )
}

#Preview(
    "Dynamic Island Expanded",
    as: .dynamicIsland(.expanded),
    using: StepActivityAttributes(goalSteps: 10000)
) {
    StepLiveActivity()
} contentStates: {
    StepActivityAttributes.ContentState(
        elapsedSeconds: 66,
        isPaused: false,
        steps: 100,
        distance: 75,
        floorsAscended: 0,
        floorsDescended: 0
    )
}

#Preview(
    "Dynamic Island Minimal",
    as: .dynamicIsland(.minimal),
    using: StepActivityAttributes(goalSteps: 10000)
) {
    StepLiveActivity()
} contentStates: {
    StepActivityAttributes.ContentState(
        elapsedSeconds: 66,
        isPaused: false,
        steps: 100,
        distance: 75,
        floorsAscended: 0,
        floorsDescended: 0
    )
}
