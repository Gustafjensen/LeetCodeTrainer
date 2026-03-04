import SwiftUI

struct SplashScreenView: View {
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Theme.surface.ignoresSafeArea()
            LogoAnimationView(onComplete: onComplete)
            VStack {
                Spacer()
                Text("powered by Even More")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.bottom, 32)
            }
        }
    }
}
