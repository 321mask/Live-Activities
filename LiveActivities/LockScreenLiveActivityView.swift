//
//  LockScreenLiveActivityView.swift
//  Live Activities
//
//  Created by Arseny Prostakov on 16/11/25.
//

import WidgetKit
import ActivityKit
import SwiftUI

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<StepActivityAttributes>
    
    var body: some View {
        VStack(spacing: 5) {
            // Status Badge
            HStack {
                Image(systemName: context.state.isPaused ? "pause.fill" : "play.fill")
                    .font(.system(size: 13))
                Text(context.state.isPaused ? "Paused" : "In Progress")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(.green)
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            .background(.green.opacity(0.15))
            .clipShape(Capsule())
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Main Stats
            HStack(alignment: .top) {
                // Step Count
                VStack(alignment: .leading, spacing: 0) {
                    Text("STEP COUNT")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(context.state.steps)")
                        .font(.system(size: 30, weight: .regular))
                        .monospacedDigit()
                }
                
                Spacer()
                
                // Total Time
                VStack(alignment: .trailing, spacing: 0) {
                    Text("TOTAL TIME")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(formatTime(context.state.elapsedSeconds))
                        .font(.system(size: 30, weight: .regular))
                        .monospacedDigit()
                }
            }
            .padding(.vertical, 12)
            
            // Progress Bar
            HStack(alignment: .center, spacing: 10) {
                Text("\(progressPercentage(steps: context.state.steps, goal: context.attributes.goalSteps))% done")
                    .font(.subheadline)
                    .bold()
                
                ProgressView(value: Double(context.state.steps), total: Double(context.attributes.goalSteps))
                    .tint(.primary)
            }
        }
        .padding(14)
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

#Preview("Lock Screen", as: .content, using: StepActivityAttributes(goalSteps: 10000)) {
    StepLiveActivity()
} contentStates: {
    StepActivityAttributes.ContentState(
        elapsedSeconds: 66,
        isPaused: false,
        steps: 6,
        distance: 4.5,
        floorsAscended: 0,
        floorsDescended: 0
    )
    
    StepActivityAttributes.ContentState(
        elapsedSeconds: 3600,
        isPaused: false,
        steps: 5000,
        distance: 3500,
        floorsAscended: 5,
        floorsDescended: 2
    )
}
