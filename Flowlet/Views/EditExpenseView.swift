import SwiftUI

struct EditExpenseView: View {
    
    let expense: Expense
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String = ""
    @State private var selectedCategory: ExpenseCategory = .food
    @State private var date: Date = Date()
    @State private var note: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Сумма", text: $amount)
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
                
                Section {
                    DatePicker("Дата", selection: $date, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                } header: {
                    Text("Дата")
                }
                
                Section {
                    TextField("Необязательно", text: $note)
                        .keyboardType(.default)
                } header: {
                    Text("Комментарий")
                }
            }
            .navigationTitle("Редактирование")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveChanges()
                    }
                    .disabled(!isAmountValid)
                }
            }
            .onAppear {
                amount = Self.amountFieldString(from: expense.amount)
                selectedCategory = expense.category
                date = expense.date
                note = expense.note ?? ""
            }
        }
    }
    
    private var isAmountValid: Bool {
        guard let value = Double(amount.replacingOccurrences(of: ",", with: ".")) else { return false }
        return value > 0
    }
    
    private func saveChanges() {
        let normalized = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountDouble = Double(normalized), amountDouble > 0 else { return }
        
        let updated = Expense(
            id: expense.id,
            amount: amountDouble,
            category: selectedCategory,
            date: date,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note
        )
        viewModel.updateExpense(updated)
        dismiss()
    }
    
    private static func amountFieldString(from value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...2)).grouping(.never))
    }
}
