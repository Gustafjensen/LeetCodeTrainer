import SwiftUI

struct SplashScreenView: View {
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Theme.surface.ignoresSafeArea()
            LogoAnimationView(onComplete: onComplete)
        }
    }
}
