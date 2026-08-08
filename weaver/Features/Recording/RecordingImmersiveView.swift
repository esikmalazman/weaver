import SwiftUI

struct RecordingImmersiveView: View {
    @Environment(RecordingViewModel.self) private var viewModel

    var body: some View {
        HandJointsRealityView(frame: viewModel.latestFrame, recenterOnWrist: false)
    }
}
