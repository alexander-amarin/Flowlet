import SwiftUI

struct AddExpenseView: View {
    
    // Подключаем viewModel
    @ObservedObject var viewModel: ExpenseViewModel
    
    // Закрытие окна
    @Environment(\.dismiss) var dismiss
    
    // Временные данные формы - пока пользователь не введет свои
    @State private var amount: String = ""
    @State private var selectedCategory: ExpenseCategory = .food
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section {
                    TextField("Введите сумму", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.system(.body, design: .rounded))
                } header: {
                    Text("Сумма")
                }
                
                Section {
                    Picker("Категория", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases) { category in
                            Label {
                                Text(category.rawValue)
                            } icon: {
                                Image(systemName: category.systemImage)
                                    .foregroundStyle(category.color)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.inline)
                } header: {
                    Text("Категория")
                }
            }
            .navigationTitle("Новый расход")
            .toolbar {
                
                // Кнопка отмены
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                // Кнопка сохранить
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveExpense()
                    }
                }
            }
        }
    }
    private func saveExpense() {
        guard let amountDouble = Double(amount) else { return }
        
        viewModel.addExpense(
            amount: amountDouble,
            category: selectedCategory,
            note: nil)
        
        dismiss()
    }
}
