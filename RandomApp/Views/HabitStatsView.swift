import SwiftUI
import Charts

struct HabitStatsView: View {
    let habit: Habit
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Achievement Cards
                HStack(spacing: 16) {
                    StatCard(
                        title: "Longest Streak",
                        value: "\(habit.longestStreak())",
                        icon: "trophy.fill",
                        gradient: [Color(hex: "F59E0B"), Color(hex: "D97706")]
                    )
                    
                    StatCard(
                        title: "Total Days",
                        value: "\(habit.completedDates.count)",
                        icon: "calendar.badge.clock",
                        gradient: [Color(hex: "8B5CF6"), Color(hex: "6366F1")]
                    )
                }
                
                // Weekly Pattern
                WeeklyPatternView(habit: habit)
                
                // Monthly Progress
                MonthlyProgressView(habit: habit)
                
                // Category Info
                CategoryInfoView(category: habit.category)
            }
            .padding()
        }
        .background(Theme.background)
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct WeeklyPatternView: View {
    let habit: Habit
    let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    struct WeekdayData: Identifiable {
        let id = UUID()
        let day: String
        let count: Int
    }
    
    var chartData: [WeekdayData] {
        let completions = habit.completionsByWeekday()
        return weekdays.enumerated().map { index, day in
            WeeklyPatternView.WeekdayData(
                day: day,
                count: completions[index + 1, default: 0]
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Pattern")
                .font(.system(.title3, design: .rounded, weight: .bold))
            
            Chart(chartData) { data in
                BarMark(
                    x: .value("Day", data.day),
                    y: .value("Count", data.count)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(hex: habit.category.color[0]),
                            Color(hex: habit.category.color[1])
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
            .frame(height: 200)
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
    }
}

struct MonthlyProgressView: View {
    let habit: Habit
    
    struct MonthData: Identifiable {
        let id = UUID()
        let month: Date
        let completion: Double
    }
    
    var chartData: [MonthData] {
        habit.monthlyProgress().map { progress in
            MonthData(month: progress.month, completion: progress.completion)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Progress")
                .font(.system(.title3, design: .rounded, weight: .bold))
            
            Chart(chartData) { item in
                LineMark(
                    x: .value("Month", item.month, unit: .month),
                    y: .value("Completion", item.completion)
                )
                .foregroundStyle(Color(hex: habit.category.color[0]))
                
                AreaMark(
                    x: .value("Month", item.month, unit: .month),
                    y: .value("Completion", item.completion)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(hex: habit.category.color[0]).opacity(0.3),
                            Color(hex: habit.category.color[1]).opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(height: 200)
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
    }
}

struct CategoryInfoView: View {
    let category: Habit.Category
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: category.icon)
                .font(.title)
                .foregroundStyle(Color(hex: category.color[0]))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue.capitalized)
                    .font(.system(.headline, design: .rounded))
                Text("Category")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Theme.subtleText)
            }
            
            Spacer()
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
    }
} 