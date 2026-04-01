import Foundation
import SwiftUI

/// Базовые категории расходов (порядок `allCases` — для списков и онбординга).
enum ExpenseCategory: String, CaseIterable, Identifiable {
    
    case food = "Еда"
    case transport = "Транспорт"
    case housing = "Жильё"
    case shopping = "Покупки"
    case entertainment = "Развлечения"
    case health = "Здоровье"
    case education = "Образование"
    case other = "Прочее"
    
    var id: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .housing: return "house.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "gamecontroller.fill"
        case .health: return "cross.case.fill"
        case .education: return "book.fill"
        case .other: return "shippingbox.fill"
        }
    }
    
    var icon: String {
        switch self {
        case .food: return "🍔"
        case .transport: return "🚕"
        case .housing: return "🏠"
        case .shopping: return "🛍"
        case .entertainment: return "🎮"
        case .health: return "💊"
        case .education: return "📚"
        case .other: return "📦"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .orange
        case .transport: return .blue
        case .housing: return .brown
        case .shopping: return .pink
        case .entertainment: return .purple
        case .health: return .red
        case .education: return .indigo
        case .other: return .gray
        }
    }
}

// MARK: - Codable (миграция со старых сохранённых значений)

extension ExpenseCategory: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        if let match = ExpenseCategory(rawValue: raw) {
            self = match
            return
        }
        switch raw {
        case "Другое":
            self = .other
        case "Подписки":
            self = .shopping
        default:
            self = .other
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
