import Foundation
import FirebaseAuth

/// Слой доступа к Firebase Authentication без UI.
final class AuthService {
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    /// Есть ли активная сессия Firebase.
    var isUserSignedIn: Bool {
        Auth.auth().currentUser != nil
    }
    
    /// Email текущего пользователя (если есть).
    var currentUserEmail: String? {
        Auth.auth().currentUser?.email
    }
    
    deinit {
        if let authStateListener {
            Auth.auth().removeStateDidChangeListener(authStateListener)
        }
    }
    
    /// Подписка на смену состояния авторизации (вызывается на главном потоке Firebase).
    func startObservingAuthState(onChange: @escaping @Sendable (Bool) -> Void) {
        authStateListener = Auth.auth().addStateDidChangeListener { _, user in
            onChange(user != nil)
        }
    }
    
    func register(email: String, password: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Auth.auth().createUser(withEmail: email, password: password) { _, error in
                if let error {
                    continuation.resume(throwing: Self.mapFirebaseError(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Auth.auth().signIn(withEmail: email, password: password) { _, error in
                if let error {
                    continuation.resume(throwing: Self.mapFirebaseError(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - Ошибки
    
    enum AuthServiceError: LocalizedError {
        case invalidEmail
        case wrongPassword
        case userNotFound
        case emailAlreadyInUse
        case weakPassword
        case network
        case tooManyRequests
        case userDisabled
        case invalidCredential
        case unknown(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidEmail:
                return "Некорректный адрес email."
            case .wrongPassword:
                return "Неверный пароль."
            case .userNotFound:
                return "Пользователь с таким email не найден."
            case .emailAlreadyInUse:
                return "Этот email уже зарегистрирован. Войдите или используйте другой адрес."
            case .weakPassword:
                return "Пароль слишком простой. Используйте не менее 6 символов."
            case .network:
                return "Проблема с сетью. Проверьте подключение к интернету."
            case .tooManyRequests:
                return "Слишком много попыток. Попробуйте позже."
            case .userDisabled:
                return "Аккаунт отключён. Обратитесь в поддержку."
            case .invalidCredential:
                return "Неверный email или пароль."
            case .unknown(let message):
                return message.isEmpty ? "Произошла ошибка. Попробуйте снова." : message
            }
        }
    }
    
    private static func mapFirebaseError(_ error: Error) -> AuthServiceError {
        let ns = error as NSError
        guard let code = AuthErrorCode(rawValue: ns.code) else {
            return .unknown(error.localizedDescription)
        }
        switch code {
        case .invalidEmail:
            return .invalidEmail
        case .wrongPassword:
            return .wrongPassword
        case .userNotFound:
            return .userNotFound
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .network
        case .tooManyRequests:
            return .tooManyRequests
        case .userDisabled:
            return .userDisabled
        case .invalidCredential:
            return .invalidCredential
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
