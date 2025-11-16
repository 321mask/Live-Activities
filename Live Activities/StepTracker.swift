//
//  StepTracker.swift
//  Live Activities
//
//  Created by Arseny Prostakov on 16/11/25.
//

import ActivityKit
import CoreMotion
import Foundation
import Observation

@Observable
class StepTracker {
    private let pedometer = CMPedometer()
    private(set) var activity: Activity<StepActivityAttributes>?

    private var timerTask: Task<Void, Never>?
    var isPaused = false
    var elapsedSeconds: Int = 0
    var steps: Int = 0
    var distance: Double = 0
    var floorsAscended: Int = 0
    var floorsDescended: Int = 0

    // Track last update to avoid unnecessary updates
    private var lastUpdateTime: Date = .distantPast
    private let minUpdateInterval: TimeInterval = 1.0  // Update at most once per second

    func startTracking(goalSteps: Int) {
        guard CMPedometer.isStepCountingAvailable() else {
            print("Step counting not available")
            return
        }

        // Reset all state to zero for new session
        elapsedSeconds = 0
        steps = 0
        distance = 0
        floorsAscended = 0
        floorsDescended = 0
        isPaused = false
        lastUpdateTime = .distantPast

        // 1) Start Activity
        let attributes = StepActivityAttributes(goalSteps: goalSteps)
        let initialState = StepActivityAttributes.ContentState(
            elapsedSeconds: 0,
            isPaused: false,
            steps: 0,
            distance: 0,
            floorsAscended: 0,
            floorsDescended: 0
        )

        do {
            activity = try Activity<StepActivityAttributes>.request(
                attributes: attributes,
                content: ActivityContent(state: initialState, staleDate: nil),
                pushType: nil
            )
            print("✅ Activity started: \(String(describing: activity?.id))")
        } catch {
            print("❌ Error requesting activity: \(error)")
            return
        }

        // 2) Start pedometer updates (happens ~60Hz, but we'll throttle)
        pedometer.startUpdates(from: .now) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else {
                if let error = error {
                    print("❌ Pedometer error: \(error)")
                }
                return
            }

            DispatchQueue.main.async {
                // Update local state immediately for UI
                self.elapsedSeconds = Int(
                    data.endDate.timeIntervalSince(data.startDate)
                )
                self.steps = data.numberOfSteps.intValue
                self.distance = data.distance?.doubleValue ?? 0
                self.floorsAscended = data.floorsAscended?.intValue ?? 0
                self.floorsDescended = data.floorsDescended?.intValue ?? 0

                // Check if goal is reached
                if self.steps >= goalSteps {
                    print("🎉 Goal reached! Auto-stopping...")
                    self.stopTracking()
                }
            }
        }

        // 3) Start timer for frequent Live Activity updates (1 Hz)
        startTimer()

        print("🏃 Step tracking started with goal: \(goalSteps) steps")
    }

    func stopTracking() {
        print("🛑 Stopping step tracking...")

        // Stop timer first
        timerTask?.cancel()
        timerTask = nil

        // Stop pedometer
        pedometer.stopUpdates()

        // End activity with final state
        Task {
            guard let activity = activity else { return }

            await activity.end(
                ActivityContent(
                    state: contentState(),
                    staleDate: nil
                ),
                dismissalPolicy: .immediate
            )

            self.activity = nil
            print("✅ Activity ended")
        }
    }

    func pauseTracking() {
        isPaused = true
        Task {
            await pushUpdate()
        }
        print("⏸️ Tracking paused")
    }

    func resumeTracking() {
        isPaused = false
        Task {
            await pushUpdate()
        }
        print("▶️ Tracking resumed")
    }

    // MARK: - Private Methods

    private func startTimer() {
        timerTask?.cancel()

        timerTask = Task { [weak self] in
            guard let self else { return }

            // Align to the next full second
            let delay =
                1.0
                - Date().timeIntervalSinceReferenceDate.truncatingRemainder(
                    dividingBy: 1.0
                )
            try? await Task.sleep(for: .seconds(delay))

            while !Task.isCancelled {
                // Update elapsed time if not paused
                if !self.isPaused {
                    self.elapsedSeconds += 1
                }

                // Push update to Live Activity (this is the frequent update)
                await self.pushUpdate()

                // Wait for next second
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    private func pushUpdate() async {
        guard let activity = activity else { return }

        // Throttle updates (shouldn't be needed with 1s timer, but good practice)
        let now = Date()
        guard now.timeIntervalSince(lastUpdateTime) >= minUpdateInterval else {
            return
        }
        lastUpdateTime = now

        let state = contentState()

        // Update with frequent updates enabled (up to 1 Hz on Lock Screen)
        await activity.update(
            ActivityContent(
                state: state,
                staleDate: nil,
                relevanceScore: 1.0  // Keep it relevant for Dynamic Island
            )
        )

        // Debug: Log updates
        #if DEBUG
            print(
                "📊 Updated: \(steps) steps, \(String(format: "%.1f", distance))m, \(formatTime(elapsedSeconds))"
            )
        #endif
    }

    private func contentState(entryId: UUID? = nil)
        -> StepActivityAttributes.ContentState
    {
        StepActivityAttributes.ContentState(
            elapsedSeconds: min(elapsedSeconds, 86399),  // Cap at 24 hours
            isPaused: isPaused,
            steps: steps,
            distance: distance,
            floorsAscended: floorsAscended,
            floorsDescended: floorsDescended,
            entryId: entryId
        )
    }

    // MARK: - Helpers

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

    // MARK: - App Lifecycle Support

    func handleAppBackground() {
        // Optionally reduce update frequency when app backgrounds
        // For now, we keep 1s updates as iOS will throttle automatically
        print("📱 App backgrounded - continuing frequent updates")
    }

    func handleAppForeground() {
        // Ensure timer is running
        if activity != nil && timerTask == nil {
            startTimer()
        }
        print("📱 App foregrounded")
    }
}
