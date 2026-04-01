import SwiftUI

struct ExpenseRowView: View {
    
    let expense: Expense
    /// В секционном списке категория уже в заголовке — в строке показываем дату и комментарий
    var showCategoryTitle: Bool = true
    
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            categoryIcon
            
            if showCategoryTitle {
                standaloneTextBlock
            } else {
                groupedTextBlock
            }
            
            Spacer(minLength: 8)
            
            Text(formattedAmount(expense.amount))
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundStyle(expense.category.color)
                .monospacedDigit()
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
        .overlay(alignment: .leading) {
            if !showCategoryTitle {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [expense.category.color, expense.category.color.opacity(0.55)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 4)
                    .padding(.vertical, 10)
                    .padding(.leading, 6)
            }
        }
        .accessibilityElement(children: .combine)
    }
    
    private var standaloneTextBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(expense.category.rawValue)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            
            HStack(spacing: 6) {
                Text(expense.date, style: .date)
                if let note = expense.note, !note.isEmpty {
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(note)
                        .lineLimit(1)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
    
    private var groupedTextBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(expense.date, style: .date)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            
            if let note = expense.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            } else {
                Text("Без комментария")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    private var categoryIcon: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            expense.category.color.opacity(0.95),
                            expense.category.color.opacity(0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: showCategoryTitle ? 48 : 42, height: showCategoryTitle ? 48 : 42)
            
            Image(systemName: expense.category.systemImage)
                .font(.system(size: showCategoryTitle ? 20 : 18, weight: .semibold))
                .foregroundStyle(.white)
                .symbolRenderingMode(.hierarchical)
        }
        .accessibilityHidden(true)
    }
    
    private func formattedAmount(_ value: Double) -> String {
        let n = value.formatted(.number.precision(.fractionLength(0...2)).grouping(.automatic))
        return "\(n) ₴"
    }
}
