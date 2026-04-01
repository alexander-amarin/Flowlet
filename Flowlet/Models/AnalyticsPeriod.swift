import Foundation

/// Период для фильтрации аналитики и графиков
enum AnalyticsPeriod: String, CaseIterable, Identifiable {
    case week
    case month
    case year
    case allTime
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .week: return "Неделя"
        case .month: return "Месяц"
        case .year: return "Год"
        case .allTime: return "Всё время"
        }
    }
    
    var emoji: String {
        switch self {
        case .week: return "📅"
        case .month: return "📆"
        case .year: return "🗓"
        case .allTime: return "🌍"
        }
    }
    
    /// Короткая подпись для компактного сегмента
    var shortTitle: String {
        switch self {
        case .week: return "Неделя"
        case .month: return "Месяц"
        case .year: return "Год"
        case .allTime: return "Всё"
        }
    }
    
    /// Подпись для блока сводки
    var summaryHeadline: String {
        switch self {
        case .week: return "За неделю"
        case .month: return "За месяц"
        case .year: return "За год"
        case .allTime: return "Всего"
        }
    }
}
