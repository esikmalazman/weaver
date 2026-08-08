import SwiftUI

/// Placeholder practice-palette window until real pattern/color content is added.
struct PaletteWindow: View {
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 48))
            Text("Palette")
                .font(AppFont.title)
        }
        .foregroundStyle(AppColor.textSecondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}
