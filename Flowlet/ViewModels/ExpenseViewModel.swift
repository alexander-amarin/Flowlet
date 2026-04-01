import SwiftUI
import Foundation
internal import Combine

/// Состояние для UI и вызовы в `ExpenseRepository` (без прямой работы с хранилищем).
final class ExpenseViewModel: ObservableObject {
    
    @Published private(set) var expenses: [Expense] = []
    
    private let repository: ExpenseRepository
    
    init(repository: ExpenseRepository = ExpenseRepository()) {
        self.repository = repository
        self.expenses = repository.expenses
    }
    
    private func syncFromRepository() {
        expenses = repository.expenses
    }
    
    // MARK: - CRUD (делегирование в Repository)
    
    func addExpense(amount: Double, category: ExpenseCategory, note: String?) {
        repository.addExpense(amount: amount, category: category, note: note)
        syncFromRepository()
    }
    
    func updateExpense(_ updated: Expense) {
        repository.updateExpense(updated)
        syncFromRepository()
    }
    
    func deleteExpenses(in category: ExpenseCategory, at offsets: IndexSet) {
        repository.deleteExpenses(in: category, at: offsets)
        syncFromRepository()
    }
    
    func groupedExpenses() -> [ExpenseCategory: [Expense]] {
        repository.groupedExpenses()
    }
    
    // MARK: - Аналитика
    
    func expenses(for period: AnalyticsPeriod, now: Date = Date()) -> [Expense] {
        repository.expenses(for: period, now: now)
    }
    
    func totalExpenseAmount(for period: AnalyticsPeriod, now: Date = Date()) -> Double {
        repository.totalExpenseAmount(for: period, now: now)
    }
    
    func categoryTotalsDescending(for period: AnalyticsPeriod, now: Date = Date()) -> [(category: ExpenseCategory, total: Double)] {
        repository.categoryTotalsDescending(for: period, now: now)
    }
    
    func dailyExpenseTotals(for period: AnalyticsPeriod, now: Date = Date()) -> [(day: Date, total: Double)] {
        repository.dailyExpenseTotals(for: period, now: now)
    }
}
