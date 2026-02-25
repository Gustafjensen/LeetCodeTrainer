import SwiftUI

struct LogoAnimationView: View {
    var showTitle: Bool = true
    var onComplete: (() -> Void)?

    @State private var bracketsScale: CGFloat = 0
    @State private var bracketsOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 12
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 20) {
            // < / > brackets
            Text("< / >")
                .font(.system(size: 52, weight: .bold, design: .monospaced))
                .foregroundStyle(Theme.accent)
                .scaleEffect(bracketsScale * pulseScale)
                .opacity(bracketsOpacity)

            // App name
            if showTitle {
                Text("Even More Code")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Theme.textPrimary)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)
            }
        }
        .onAppear {
            // Step 1: Brackets bounce in
            withAnimation(.spring(duration: 0.5, bounce: 0.4).delay(0.3)) {
                bracketsScale = 1.0
                bracketsOpacity = 1.0
            }

            // Step 2: Title fades in
            if showTitle {
                withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
                    titleOpacity = 1.0
                    titleOffset = 0
                }
            }

            // Step 3: Subtle pulse on brackets
            withAnimation(.easeInOut(duration: 0.6).delay(1.5)) {
                pulseScale = 1.08
            }
            withAnimation(.easeInOut(duration: 0.4).delay(2.1)) {
                pulseScale = 1.0
            }

            // Complete callback
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onComplete?()
            }
        }
    }
}
