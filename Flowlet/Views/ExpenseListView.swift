import SwiftUI

struct ExpenseListView: View {
    
    @ObservedObject var viewModel: ExpenseViewModel
    
    @State private var isShowingAddExpense = false
    @State private var expenseToEdit: Expense?
    
    var body: some View {
        Group {
            if viewModel.expenses.isEmpty {
                expensesEmptyState
            } else {
                expensesList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Расходы")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingAddExpense = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.body.weight(.semibold))
                }
                .accessibilityLabel("Добавить расход")
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    StatisticsView(viewModel: viewModel)
                } label: {
                    Image(systemName: "chart.bar.xaxis")
                        .symbolRenderingMode(.hierarchical)
                }
                .accessibilityLabel("Статистика")
            }
        }
        .sheet(isPresented: $isShowingAddExpense) {
            AddExpenseView(viewModel: viewModel)
        }
        .sheet(item: $expenseToEdit) { expense in
            EditExpenseView(expense: expense, viewModel: viewModel)
        }
    }
    
    private var expensesEmptyState: some View {
        ContentUnavailableView {
            VStack(spacing: 12) {
                Image(systemName: "tray")
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text("Нет расходов")
                    .font(.title2.weight(.semibold))
            }
        } description: {
            Text("Добавьте первую запись — нажмите «+» вверху справа.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        } actions: {
            Button {
                isShowingAddExpense = true
            } label: {
                Label("Добавить расход", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(.bottom, 24)
    }
    
    private var grouped: [ExpenseCategory: [Expense]] {
        viewModel.groupedExpenses()
    }
    
    private var expensesList: some View {
        List {
            ForEach(ExpenseCategory.allCases, id: \.self) { category in
                if let sectionExpenses = grouped[category], !sectionExpenses.isEmpty {
                    let rows = sectionExpenses.sorted { $0.date > $1.date }
                    let sectionTotal = rows.reduce(0) { $0 + $1.amount }
                    Section {
                        ForEach(rows) { expense in
                            Button {
                                expenseToEdit = expense
                            } label: {
                                ExpenseRowView(expense: expense, showCategoryTitle: false)
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("Открыть редактирование")
                            .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete { offsets in
                            viewModel.deleteExpenses(in: category, at: offsets)
                        }
                    } header: {
                        CategorySectionHeader(
                            category: category,
                            count: rows.count
                        )
                    } footer: {
                        CategorySectionFooter(total: sectionTotal, accent: category.color)
                    }
                }
            }
        }
        .listStyle(.plain)
        .listSectionSpacing(20)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 0)
    }
}

// MARK: - Секции группировки

private struct CategorySectionHeader: View {
    let category: ExpenseCategory
    let count: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                category.color.opacity(0.92),
                                category.color.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: category.color.opacity(0.35), radius: 8, x: 0, y: 3)
                
                Image(systemName: category.systemImage)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolRenderingMode(.hierarchical)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                
                Text(countLabel)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.top, 8)
        .padding(.bottom, 6)
        .padding(.horizontal, 2)
        .textCase(nil)
    }
    
    private var countLabel: String {
        let n = count
        let word: String
        let mod10 = n % 10
        let mod100 = n % 100
        if mod100 >= 11 && mod100 <= 14 {
            word = "записей"
        } else if mod10 == 1 {
            word = "запись"
        } else if mod10 >= 2 && mod10 <= 4 {
            word = "записи"
        } else {
            word = "записей"
        }
        return "\(n) \(word)"
    }
    
}

private struct CategorySectionFooter: View {
    let total: Double
    let accent: Color
    
    var body: some View {
        HStack {
            Spacer(minLength: 0)
            Text("Итого по категории")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Text(formatCurrency(total))
                .font(.caption.weight(.bold))
                .foregroundStyle(accent)
                .monospacedDigit()
        }
        .padding(.top, 2)
        .padding(.bottom, 4)
        .padding(.horizontal, 2)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let n = value.formatted(.number.precision(.fractionLength(0...2)).grouping(.automatic))
        return "\(n) ₴"
    }
}
