import SwiftUI

struct LoginAuthView: View {
    
    let onFinish: () -> Void
    
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    
    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isFormValid: Bool {
        AuthValidation.isValidEmail(trimmedEmail) && AuthValidation.isNonEmptyPassword(password)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Вход")
                        .font(.largeTitle.weight(.bold))
                    Text("Войдите в аккаунт, чтобы данные были с вами на всех устройствах")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 8)
                
                if let message = authViewModel.errorMessage {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        TextField("Email", text: $email)
                            .textContentType(.username)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .onChange(of: email) { _, _ in authViewModel.clearError() }
                        if !trimmedEmail.isEmpty, !AuthValidation.isValidEmail(trimmedEmail) {
                            Text("Введите корректный email")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    SecureField("Пароль", text: $password)
                        .textContentType(.password)
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .onChange(of: password) { _, _ in authViewModel.clearError() }
                }
                
                Button {
                    Task {
                        await authViewModel.signIn(email: trimmedEmail, password: password)
                        if authViewModel.isAuthenticated {
                            onFinish()
                        }
                    }
                } label: {
                    ZStack {
                        Text("Войти")
                            .font(.headline)
                            .opacity(authViewModel.isLoading ? 0 : 1)
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!isFormValid || authViewModel.isLoading)
                
                HStack(spacing: 4) {
                    Text("Нет аккаунта?")
                        .foregroundStyle(.secondary)
                    NavigationLink {
                        RegistrationView(onFinish: onFinish)
                    } label: {
                        Text("Регистрация")
                            .fontWeight(.semibold)
                    }
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Или продолжить с помощью")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                    AuthSocialIconRow(onGoogle: {}, onApple: {}, onFacebook: {})
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LoginAuthView(onFinish: {})
            .environmentObject(AuthViewModel())
    }
}
