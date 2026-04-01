import SwiftUI
import Foundation
internal import Combine

/// Состояние авторизации для UI; вызывает только `AuthService`, не Firebase напрямую.
@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published private(set) var isAuthenticated = false
    @Published var errorMessage: String?
    @Published private(set) var isLoading = false
    
    private let authService: AuthService
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
        self.isAuthenticated = authService.isUserSignedIn
        
        authService.startObservingAuthState { [weak self] signedIn in
            Task { @MainActor in
                self?.isAuthenticated = signedIn
                if signedIn {
                    self?.errorMessage = nil
                }
            }
        }
    }
    
    var currentUserEmail: String? {
        authService.currentUserEmail
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func register(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.register(email: email, password: password)
        } catch let error as AuthService.AuthServiceError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func signIn(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.signIn(email: email, password: password)
        } catch let error as AuthService.AuthServiceError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func signOut() {
        errorMessage = nil
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
