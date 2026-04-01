import SwiftUI

/// Строка иконок Google / Apple / Facebook (только UI).
struct AuthSocialIconRow: View {
    var onGoogle: () -> Void = {}
    var onApple: () -> Void = {}
    var onFacebook: () -> Void = {}
    
    var body: some View {
        HStack(spacing: 20) {
            socialButton(icon: .google, action: onGoogle)
            socialButton(icon: .apple, action: onApple)
            socialButton(icon: .facebook, action: onFacebook)
        }
        .frame(maxWidth: .infinity)
    }
    
    private enum SocialKind {
        case google, apple, facebook
    }
    
    @ViewBuilder
    private func socialButton(icon: SocialKind, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                socialIcon(for: icon)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label(for: icon))
    }
    
    @ViewBuilder
    private func socialIcon(for kind: SocialKind) -> some View {
        switch kind {
        case .google:
            Text("G")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red, .yellow, .green, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        case .apple:
            Image(systemName: "apple.logo")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(.primary)
        case .facebook:
            Text("f")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(Color(red: 0.26, green: 0.40, blue: 0.96))
        }
    }
    
    private func label(for kind: SocialKind) -> String {
        switch kind {
        case .google: return "Google"
        case .apple: return "Apple"
        case .facebook: return "Facebook"
        }
    }
}
