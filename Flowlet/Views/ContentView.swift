import SwiftUI

struct ContentView: View {
    
    @Binding var hasSeenOnboarding: Bool
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @StateObject private var viewModel = ExpenseViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                if let email = authViewModel.currentUserEmail {
                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                NavigationLink("Перейти к расходам") {
                    ExpenseListView(viewModel: viewModel)
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Flowlet")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if authViewModel.isAuthenticated {
                        Button {
                            authViewModel.signOut()
                        } label: {
                            Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        hasSeenOnboarding = false
                    } label: {
                        Label("К онбордингу", systemImage: "arrow.uturn.backward")
                    }
                    .accessibilityHint("Показать экран приветствия и входа")
                }
            }
        }
    }
}

#Preview {
    ContentView(hasSeenOnboarding: .constant(true))
        .environmentObject(AuthViewModel())
}
