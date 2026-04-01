import Foundation

/// CRUD и бизнес-логика по расходам; персистентность через `StorageService`.
final class ExpenseRepository {
    
    private let storage: StorageService
    private let saveKey = "expenses_key"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private(set) var expenses: [Expense] = []
    
    init(storage: StorageService = UserDefaultsStorageService()) {
        self.storage = storage
        loadFromStorage()
    }
    
    // MARK: - CRUD
    
    func addExpense(amount: Double, category: ExpenseCategory, note: String?) {
        let newExpense = Expense(
            id: UUID(),
            amount: amount,
            category: category,
            date: Date(),
            note: note
        )
        expenses.append(newExpense)
        persist()
    }
    
    func updateExpense(_ updated: Expense) {
        guard let index = expenses.firstIndex(where: { $0.id == updated.id }) else { return }
        expenses[index] = updated
        persist()
    }
    
    func deleteExpenses(in category: ExpenseCategory, at offsets: IndexSet) {
        let sortedInCategory = expenses
            .filter { $0.category == category }
            .sorted { $0.date > $1.date }
        let idsToRemove = Set(offsets.compactMap { index -> UUID? in
            guard sortedInCategory.indices.contains(index) else { return nil }
            return sortedInCategory[index].id
        })
        guard !idsToRemove.isEmpty else { return }
        expenses.removeAll { idsToRemove.contains($0.id) }
        persist()
    }
    
    func groupedExpenses() -> [ExpenseCategory: [Expense]] {
        Dictionary(grouping: expenses) { $0.category }
    }
    
    // MARK: - Аналитика
    
    func expenses(for period: AnalyticsPeriod, now: Date = Date()) -> [Expense] {
        let cal = Calendar.current
        switch period {
        case .allTime:
            return expenses
        case .week:
            guard let interval = cal.dateInterval(of: .weekOfYear, for: now) else { return expenses }
            return expenses.filter { $0.date >= interval.start && $0.date <= now }
        case .month:
            guard let start = cal.date(from: cal.dateComponents([.year, .month], from: now)) else { return [] }
            return expenses.filter { $0.date >= start && $0.date <= now }
        case .year:
            let y = cal.component(.year, from: now)
            guard let start = cal.date(from: DateComponents(year: y, month: 1, day: 1)) else { return [] }
            return expenses.filter { $0.date >= start && $0.date <= now }
        }
    }
    
    func totalExpenseAmount(for period: AnalyticsPeriod, now: Date = Date()) -> Double {
        expenses(for: period, now: now).reduce(0) { $0 + $1.amount }
    }
    
    func categoryTotalsDescending(for period: AnalyticsPeriod, now: Date = Date()) -> [(category: ExpenseCategory, total: Double)] {
        var sums: [ExpenseCategory: Double] = [:]
        for expense in expenses(for: period, now: now) {
            sums[expense.category, default: 0] += expense.amount
        }
        return sums
            .map { (category: $0.key, total: $0.value) }
            .filter { $0.total > 0 }
            .sorted { $0.total > $1.total }
    }
    
    func dailyExpenseTotals(for period: AnalyticsPeriod, now: Date = Date()) -> [(day: Date, total: Double)] {
        let cal = Calendar.current
        var byDay: [Date: Double] = [:]
        for expense in expenses(for: period, now: now) {
            let start = cal.startOfDay(for: expense.date)
            byDay[start, default: 0] += expense.amount
        }
        return byDay
            .map { (day: $0.key, total: $0.value) }
            .sorted { $0.day < $1.day }
    }
    
    // MARK: - Persistence
    
    private func loadFromStorage() {
        guard let data = storage.data(forKey: saveKey) else { return }
        do {
            expenses = try decoder.decode([Expense].self, from: data)
        } catch {
            print("❌ Ошибка загрузки расходов:", error)
        }
    }
    
    private func persist() {
        do {
            let data = try encoder.encode(expenses)
            storage.save(data, forKey: saveKey)
        } catch {
            print("❌ Ошибка сохранения расходов:", error)
        }
    }
}
