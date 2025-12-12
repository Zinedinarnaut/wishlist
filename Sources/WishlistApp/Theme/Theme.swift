import SwiftUI

struct AppTheme {
    static let accent = Color(red: 0.72, green: 0.79, blue: 0.92)
    static let background = LinearGradient(
        colors: [Color.black, Color(red: 0.08, green: 0.09, blue: 0.11)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let cardGradient = LinearGradient(
        gradient: Gradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.02)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let shadow = Color.black.opacity(0.45)
}

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppTheme.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .shadow(color: AppTheme.shadow, radius: 16, x: 0, y: 10)
    }
}

extension View {
    func glassCard() -> some View { modifier(GlassCard()) }
}

enum Haptics {
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: style).impactOccurred()
        #endif
    }
}
