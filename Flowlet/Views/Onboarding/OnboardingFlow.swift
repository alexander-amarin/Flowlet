import SwiftUI

/// Корневой контейнер онбординга: навигация к заглушкам входа и регистрации.
struct OnboardingFlow: View {
    @Binding var hasSeenOnboarding: Bool
    
    var body: some View {
        NavigationStack {
            WelcomeOnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
        }
    }
}

// MARK: - Приветствие

private struct WelcomeOnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Spacer(minLength: 12)
                    
                    Text("Чтобы не потерять ваши данные и сохранить расходы на всех устройствах, войдите в аккаунт")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Базовые категории расходов")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(ExpenseCategory.allCases) { category in
                                HStack(spacing: 12) {
                                    Text(category.icon)
                                        .font(.title2)
                                        .frame(width: 36, alignment: .center)
                                    Text(category.rawValue)
                                        .font(.body)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        
                        Button {
                            hasSeenOnboarding = true
                        } label: {
                            Text("Добавь свои собственные расходы")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(spacing: 12) {
                        NavigationLink {
                            LoginAuthView(onFinish: { hasSeenOnboarding = true })
                        } label: {
                            Text("Войти")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        NavigationLink {
                            RegistrationView(onFinish: { hasSeenOnboarding = true })
                        } label: {
                            Text("Регистрация")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Войти с помощью")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        AuthSocialIconRow(
                            onGoogle: { hasSeenOnboarding = true },
                            onApple: { hasSeenOnboarding = true },
                            onFacebook: { hasSeenOnboarding = true }
                        )
                    }
                    .padding(.top, 8)
                    
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
            
            Button {
                hasSeenOnboarding = true
            } label: {
                Text("Пропустить")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 28)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Onboarding") {
    OnboardingFlow(hasSeenOnboarding: .constant(false))
        .environmentObject(AuthViewModel())
}
