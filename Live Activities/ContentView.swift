//
//  ContentView.swift
//  Live Activities
//
//  Created by Arseny Prostakov on 16/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var tracker = StepTracker()
    @State private var isTracking = false
    @State private var goalSteps = 10000
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Section {
                Picker("Goal Steps", selection: $goalSteps) {
                    ForEach(
                        Array(stride(from: 1000, through: 50000, by: 1000)),
                        id: \.self
                    ) { step in
                        Text("\(step) steps").tag(step)
                    }
                }
                .pickerStyle(.wheel)
            }

            Section {
                Text("Selected: \(goalSteps) steps")
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Section {
                VStack(spacing: 16) {
                    Text("\(tracker.steps) steps")
                        .font(.largeTitle)

                    Text(formatDistance(tracker.distance))
                        .font(.title2)

                    Text(formatTime(tracker.elapsedSeconds))
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    if isTracking {
                        HStack {
                            Button(tracker.isPaused ? "Resume" : "Pause") {
                                if tracker.isPaused {
                                    tracker.resumeTracking()
                                } else {
                                    tracker.pauseTracking()
                                }
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Stop") {
                                tracker.stopTracking()
                                isTracking = false
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                        .controlSize(.large)
                        .font(.headline)
                    } else {
                        Button("Start Tracking") {
                            tracker.startTracking(goalSteps: goalSteps)
                            isTracking = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .font(.headline)
                        .tint(.green)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            .padding()
            .onChange(of: scenePhase) { oldPhase, newPhase in
                // Handle app lifecycle using SwiftUI's scenePhase
                switch newPhase {
                case .background:
                    tracker.handleAppBackground()
                case .active:
                    tracker.handleAppForeground()
                case .inactive:
                    break
                @unknown default:
                    break
                }
            }
        }
    }

    func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return String(format: "%.0f m", meters)
        }
        return String(format: "%.2f km", meters / 1000)
    }

    func formatTime(_ seconds: Int) -> String {
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

#Preview {
    ContentView()
}
