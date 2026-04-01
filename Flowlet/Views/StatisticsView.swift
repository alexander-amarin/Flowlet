import SwiftUI
import Charts

struct StatisticsView: View {
    
    @ObservedObject var viewModel: ExpenseViewModel
    
    @State private var selectedPeriod: AnalyticsPeriod = .month
    
    private var filteredExpenses: [Expense] {
        viewModel.expenses(for: selectedPeriod)
    }
    
    var body: some View {
        Group {
            if viewModel.expenses.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        periodPickerCard
                        
                        if filteredExpenses.isEmpty {
                            emptyForSelectedPeriod
                        } else {
                            summaryCard
                            
                            AnalyticsSectionCard(
                                title: "Распределение по категориям",
                                subtitle: "Доля каждой категории · \(selectedPeriod.summaryHeadline.lowercased())"
                            ) {
                                categoryDonutChart
                                categoryBreakdownList
                            }
                            
                            AnalyticsSectionCard(
                                title: "Сравнение категорий",
                                subtitle: "Суммы за выбранный период"
                            ) {
                                categoryHorizontalBarChart
                            }
                            
                            AnalyticsSectionCard(
                                title: "Динамика по дням",
                                subtitle: "Траты по дням внутри выбранного периода"
                            ) {
                                dailyLineChart
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Аналитика")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var emptyState: some View {
        ContentUnavailableView {
            Label("Нет данных", systemImage: "chart.bar.xaxis")
                .font(.title2.weight(.semibold))
        } description: {
            Text("Добавьте расходы на вкладке «Расходы», чтобы увидеть графики и распределение по категориям.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var emptyForSelectedPeriod: some View {
        ContentUnavailableView {
            Label("Нет расходов за период", systemImage: "calendar.badge.clock")
                .font(.title3.weight(.semibold))
        } description: {
            Text("За \(selectedPeriod.title.lowercased()) записей нет. Выберите другой интервал или добавьте траты с датой в этом диапазоне.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 32)
        .padding(.horizontal)
    }
    
    // MARK: - Период
    
    private var periodPickerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Период")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(AnalyticsPeriod.allCases) { period in
                        periodChip(period)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
        .padding(.horizontal, 16)
    }
    
    private func periodChip(_ period: AnalyticsPeriod) -> some View {
        let selected = selectedPeriod == period
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPeriod = period
            }
        } label: {
            HStack(spacing: 6) {
                Text(period.emoji)
                Text(period.shortTitle)
                    .font(.subheadline.weight(selected ? .semibold : .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(selected ? Color.accentColor : Color(.tertiarySystemGroupedBackground))
            }
            .foregroundStyle(selected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(period.title), \(selected ? "выбрано" : "не выбрано")")
    }
    
    // MARK: - Сводка
    
    private var summaryCard: some View {
        let total = viewModel.totalExpenseAmount(for: selectedPeriod)
        let count = filteredExpenses.count
        let avg = count > 0 ? total / Double(count) : 0
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedPeriod.summaryHeadline)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(formatCurrency(total))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
                Spacer()
                Image(systemName: "creditcard.fill")
                    .font(.title)
                    .foregroundStyle(.secondary.opacity(0.35))
            }
            
            HStack(spacing: 0) {
                summaryMiniStat(title: "Операций", value: "\(count)")
                Divider().frame(height: 36)
                summaryMiniStat(title: "В среднем", value: formatCurrency(avg))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
        .padding(.horizontal, 16)
    }
    
    private func summaryMiniStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
    }
    
    // MARK: - Кольцевая диаграмма
    
    private var categoryChartData: [(category: ExpenseCategory, total: Double)] {
        viewModel.categoryTotalsDescending(for: selectedPeriod)
    }
    
    private var categoryDonutChart: some View {
        Chart(categoryChartData, id: \.category) { item in
            SectorMark(
                angle: .value("Сумма", item.total),
                innerRadius: .ratio(0.56),
                angularInset: 1.5
            )
            .cornerRadius(3)
            .foregroundStyle(item.category.color.gradient)
        }
        .chartLegend(.hidden)
        .chartBackground { _ in
            GeometryReader { geo in
                let total = viewModel.totalExpenseAmount(for: selectedPeriod)
                VStack(spacing: 2) {
                    Text(formatCurrency(total))
                        .font(.title3.weight(.bold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.8)
                    Text(selectedPeriod.summaryHeadline.lowercased())
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .frame(width: geo.size.width * 0.42, height: geo.size.height * 0.42)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
        .frame(height: 260)
    }
    
    private var categoryBreakdownList: some View {
        let total = viewModel.totalExpenseAmount(for: selectedPeriod)
        return VStack(spacing: 10) {
            ForEach(categoryChartData, id: \.category) { item in
                let share = total > 0 ? item.total / total : 0
                HStack(spacing: 12) {
                    Image(systemName: item.category.systemImage)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(item.category.color.gradient, in: Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.category.rawValue)
                            .font(.subheadline.weight(.semibold))
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.primary.opacity(0.08))
                                Capsule()
                                    .fill(item.category.color.gradient)
                                    .frame(width: max(geo.size.width * share, share > 0 ? 4 : 0))
                            }
                        }
                        .frame(height: 6)
                    }
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formatCurrency(item.total))
                            .font(.caption.weight(.semibold))
                            .monospacedDigit()
                        Text(share, format: .percent.precision(.fractionLength(0...1)))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Горизонтальные столбцы
    
    private var categoryHorizontalBarChart: some View {
        Chart(categoryChartData, id: \.category) { item in
            BarMark(
                x: .value("Сумма", item.total),
                y: .value("Категория", item.category.rawValue)
            )
            .annotation(position: .trailing, alignment: .leading) {
                Text(formatCurrency(item.total))
                    .font(.caption2.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            }
            .foregroundStyle(item.category.color.gradient)
            .cornerRadius(6)
        }
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(shortCurrency(v))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let s = value.as(String.self) {
                        Text(s)
                            .font(.caption2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
            }
        }
        .frame(height: CGFloat(max(categoryChartData.count * 44, 120)))
    }
    
    // MARK: - Динамика по дням
    
    private var dailyLineChart: some View {
        let series = viewModel.dailyExpenseTotals(for: selectedPeriod)
        return Chart(series, id: \.day) { point in
            AreaMark(
                x: .value("День", point.day),
                y: .value("Сумма", point.total)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.45), Color.accentColor.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)
            
            LineMark(
                x: .value("День", point.day),
                y: .value("Сумма", point.total)
            )
            .foregroundStyle(Color.accentColor)
            .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            .interpolationMethod(.catmullRom)
            
            PointMark(
                x: .value("День", point.day),
                y: .value("Сумма", point.total)
            )
            .foregroundStyle(Color.accentColor)
            .symbolSize(series.count == 1 ? 80 : 36)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: xAxisStride)) { value in
                AxisGridLine()
                AxisValueLabel(format: xAxisLabelFormat)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(shortCurrency(v))
                    }
                }
            }
        }
        .frame(height: 220)
    }
    
    private var xAxisStride: Calendar.Component {
        switch selectedPeriod {
        case .week, .month: return .day
        case .year: return .month
        case .allTime: return .month
        }
    }
    
    private var xAxisLabelFormat: Date.FormatStyle {
        switch selectedPeriod {
        case .week, .month:
            return .dateTime.month(.abbreviated).day()
        case .year, .allTime:
            return .dateTime.month(.abbreviated).year(.twoDigits)
        }
    }
    
    // MARK: - Форматирование
    
    private func formatCurrency(_ value: Double) -> String {
        let n = value.formatted(.number.precision(.fractionLength(0...2)).grouping(.automatic))
        return "\(n) ₴"
    }
    
    private func shortCurrency(_ value: Double) -> String {
        if value >= 1000 {
            let k = value / 1000
            return String(format: "%.1fk ₴", k)
        }
        return formatCurrency(value)
    }
}

// MARK: - Карточка секции

private struct AnalyticsSectionCard<Content: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
        .padding(.horizontal, 16)
    }
}
