import SwiftUI
import FirebaseCore

@main
struct FlowletApp: App {
    
    init() {
        FirebaseApp.configure()
        #if DEBUG
        // Перед созданием UI сбрасываем флаг — иначе @AppStorage на `App` может успеть прочитать старое `true`.
        UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

/// Корень: Firebase Auth + онбординг для гостей.
private struct AppRootView: View {
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @StateObject private var authViewModel = AuthViewModel()
    
    private var showMainApp: Bool {
        authViewModel.isAuthenticated || hasSeenOnboarding
    }
    
    var body: some View {
        Group {
            if showMainApp {
                ContentView(hasSeenOnboarding: $hasSeenOnboarding)
            } else {
                OnboardingFlow(hasSeenOnboarding: $hasSeenOnboarding)
            }
        }
        .environmentObject(authViewModel)
    }
}
