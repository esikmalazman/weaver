//
//  CameraView.swift
//  weaver
//
//  Created by esikmalazman on 08/08/2026.
//

import SwiftUI

struct CameraView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    private var handSession: HandSessionController {
        appModel.handSessionController
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header

            HStack(spacing: 12) {
                Button {
                    startRecording()
                } label: {
                    Label("Record", systemImage: "record.circle")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!handSession.canRecord || appModel.immersiveSpaceState == .inTransition)

                Button {
                    handSession.stop()
                } label: {
                    Label("Stop", systemImage: "stop.circle")
                }
                .disabled(!handSession.canStop)

                Button {
                    handSession.playLatestRecording()
                } label: {
                    Label("Replay", systemImage: "play.circle")
                }
                .disabled(handSession.savedRecordings.isEmpty || handSession.state != .idle)
            }

            Text(handSession.statusText)
                .font(.callout)
                .foregroundStyle(.secondary)

            liveDetectionSummary
            recordingSummary

            Spacer(minLength: 0)
        }
        .padding(32)
        .frame(minWidth: 620, minHeight: 520)
        .onDisappear {
            if handSession.state == .playing {
                handSession.stop()
            }
            handSession.clearReplayPreview()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hand Capture")
                .font(.largeTitle)
                .fontWeight(.semibold)

            Text("Record live hand joints and voice, then replay the motion as a 3D skeleton in the immersive space.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var liveDetectionSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Detection")
                .font(.headline)

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                GridRow {
                    Text("Hands")
                        .foregroundStyle(.secondary)
                    Text("\(handSession.detectedHandCount)")
                }

                GridRow {
                    Text("Tracked Joints")
                        .foregroundStyle(.secondary)
                    Text("\(handSession.trackedJointCount) / \(handSession.detectedJointCount)")
                }

                GridRow {
                    Text("Status")
                        .foregroundStyle(.secondary)
                    Text(handSession.detectionStatusText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .font(.body)

            if let frame = handSession.currentReplayFrame, !frame.hands.isEmpty {
                Divider()

                ForEach(frame.hands, id: \.chirality) { hand in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(hand.chirality.rawValue.capitalized)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(hand.joints.filter(\.isTracked).map(\.name).joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(4)
                    }
                }
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private var recordingSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Latest Recording")
                .font(.headline)

            if let recording = handSession.savedRecordings.first?.recording {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                    GridRow {
                        Text("Created")
                            .foregroundStyle(.secondary)
                        Text(recording.createdAt.formatted(date: .abbreviated, time: .shortened))
                    }

                    GridRow {
                        Text("Duration")
                            .foregroundStyle(.secondary)
                        Text("\(recording.duration.formatted(.number.precision(.fractionLength(1)))) seconds")
                    }

                    GridRow {
                        Text("Motion Frames")
                            .foregroundStyle(.secondary)
                        Text("\(recording.frameCount)")
                    }
                }
                .font(.body)
            } else {
                Text("No recordings yet.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private func startRecording() {
        Task { @MainActor in
            if appModel.immersiveSpaceState == .closed {
                appModel.immersiveSpaceState = .inTransition
                switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
                case .opened:
                    break
                case .userCancelled, .error:
                    fallthrough
                @unknown default:
                    appModel.immersiveSpaceState = .closed
                    return
                }
            }

            guard appModel.immersiveSpaceState != .inTransition else { return }
            await handSession.startRecording()
        }
    }
}

#Preview(windowStyle: .automatic) {
    CameraView()
        .environment(AppModel())
}
