import SwiftUI

struct ConfettiView: View {
    @Binding var isActive: Bool
    @State private var particles: [ConfettiParticle] = []
    @State private var startTime: Date?
    @State private var opacity: Double = 1

    private let duration: Double = 4.0
    private let particleCount = 80
    private let colors: [Color] = [.green, .yellow, .orange, .pink, .purple, .cyan, Theme.accent]

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            Canvas { context, size in
                guard let start = startTime else { return }
                let elapsed = timeline.date.timeIntervalSince(start)

                for particle in particles {
                    let progress = elapsed / duration
                    guard progress <= 1.0 else { continue }

                    let x = particle.startX * size.width + particle.drift * CGFloat(elapsed) * 30
                    let y = particle.startY + particle.speed * CGFloat(elapsed * elapsed) * 80
                    let rotation = Angle.degrees(particle.rotationSpeed * elapsed * 360)

                    guard y < size.height + 20 else { continue }

                    context.opacity = opacity * (1.0 - progress * 0.3)
                    context.translateBy(x: x, y: y)
                    context.rotate(by: rotation)

                    let rect = CGRect(
                        x: -particle.width / 2,
                        y: -particle.height / 2,
                        width: particle.width,
                        height: particle.height
                    )

                    context.fill(
                        RoundedRectangle(cornerRadius: 1).path(in: rect),
                        with: .color(particle.color)
                    )

                    context.rotate(by: -rotation)
                    context.translateBy(x: -x, y: -y)
                }
            }
        }
        .allowsHitTesting(false)
        .onChange(of: isActive) {
            if isActive {
                spawnParticles()
                startTime = .now
                opacity = 1

                DispatchQueue.main.asyncAfter(deadline: .now() + duration * 0.5) {
                    withAnimation(.easeOut(duration: duration * 0.5)) {
                        opacity = 0
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    isActive = false
                    particles = []
                    startTime = nil
                }
            }
        }
    }

    private func spawnParticles() {
        particles = (0..<particleCount).map { _ in
            ConfettiParticle(
                startX: CGFloat.random(in: 0...1),
                startY: CGFloat.random(in: -40 ... -10),
                speed: CGFloat.random(in: 0.8...1.5),
                drift: CGFloat.random(in: -1.5...1.5),
                rotationSpeed: Double.random(in: 0.5...2.0) * (Bool.random() ? 1 : -1),
                width: CGFloat.random(in: 4...10),
                height: CGFloat.random(in: 6...14),
                color: colors.randomElement()!
            )
        }
    }
}

private struct ConfettiParticle {
    let startX: CGFloat
    let startY: CGFloat
    let speed: CGFloat
    let drift: CGFloat
    let rotationSpeed: Double
    let width: CGFloat
    let height: CGFloat
    let color: Color
}
