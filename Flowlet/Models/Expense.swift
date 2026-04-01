import Foundation

// модель одного расхода
struct Expense: Identifiable, Codable {
    
    // создаем уникальный id для работы с List
    let id: UUID
    
    // сумма расходов
    let amount: Double
    
    // Категория расходов привязана к файлу ExpenseCategory
    let category: ExpenseCategory
    
    // дата расходов
    let date: Date
    
    // Дополнительный комментарий 
    let note: String?
}
