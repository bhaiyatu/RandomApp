import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @ObservedObject var habitStore: HabitStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                CompletionButtonView(habit: habit, habitStore: habitStore)
                
                if !habit.description.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "text.alignleft")
                                .foregroundStyle(Theme.primaryColor)
                            Text("Description")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(Theme.subtleText)
                        }
                        
                        Text(habit.description)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Theme.textColor)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
                }
                
                StreakCardView(streak: habit.currentStreak())
                ProgressSectionView(habit: habit)
                StatisticsGridView(habit: habit)
                
                if let reminderTime = habit.reminderTime {
                    ReminderView(time: reminderTime)
                }
            }
            .padding()
        }
        .background(Theme.background)
        .navigationTitle(habit.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: HabitStatsView(habit: habit)) {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Theme.primaryColor)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Theme.primaryColor)
                }
            }
            
            ToolbarItem(placement: .destructiveAction) {
                DeleteButton(showingAlert: $showingDeleteAlert)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditHabitView(habit: habit, habitStore: habitStore)
        }
        .alert("Delete Habit", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                withAnimation {
                    habitStore.deleteHabit(habit)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this habit? This action cannot be undone.")
        }
    }
}

// MARK: - Supporting Views
struct CompletionButtonView: View {
    let habit: Habit
    @ObservedObject var habitStore: HabitStore
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                habitStore.toggleHabitCompletion(habit)
            }
        }) {
            HStack(spacing: 16) {
                Circle()
                    .fill(habit.isCompletedToday() ? 
                          LinearGradient(colors: [Theme.successColor, Theme.successColor.opacity(0.8)], 
                                       startPoint: .topLeading, 
                                       endPoint: .bottomTrailing) :
                          LinearGradient(colors: [Theme.secondaryColor, Theme.secondaryColor], 
                                       startPoint: .topLeading, 
                                       endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                    .overlay {
                        if habit.isCompletedToday() {
                            Image(systemName: "checkmark")
                                .font(.system(.body, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                
                Text(habit.isCompletedToday() ? "Completed Today" : "Mark as Complete")
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundStyle(habit.isCompletedToday() ? Theme.successColor : Theme.textColor)
                
                Spacer()
                
                if habit.isCompletedToday() {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.successColor)
                        .font(.title2)
                }
            }
            .padding()
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
        }
        .buttonStyle(.plain)
    }
}

struct StreakCardView: View {
    let streak: (count: Int, unit: String)
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Current Streak")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Theme.subtleText)
                
                Spacer()
                
                Image(systemName: "flame.fill")
                    .foregroundStyle(Theme.accentColor)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(streak.count)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                Text("\(streak.unit)\(streak.count == 1 ? "" : "s")")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Theme.subtleText)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
    }
}

struct ProgressSectionView: View {
    let habit: Habit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(Theme.primaryColor)
                Text("Weekly Progress")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.textColor)
            }
            
            WeeklyProgressView(habit: habit)
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
    }
}

struct StatisticsGridView: View {
    let habit: Habit
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                title: "This Week",
                value: "\(Int(habit.completionRate(for: 7) * 100))%",
                icon: "chart.line.uptrend.xyaxis",
                gradient: [Theme.primaryColor, Theme.gradientEnd]
            )
            
            StatCard(
                title: "This Month",
                value: "\(Int(habit.completionRate(for: 30) * 100))%",
                icon: "calendar",
                gradient: [Color(hex: "8B5CF6"), Color(hex: "6366F1")]
            )
        }
    }
}

struct ReminderView: View {
    let time: Date
    
    var body: some View {
        HStack {
            Image(systemName: "bell.fill")
                .foregroundStyle(Theme.accentColor)
            
            Text("Daily reminder at")
                .foregroundStyle(Theme.subtleText)
            
            Text(time.formatted(date: .omitted, time: .shortened))
                .font(.system(.body, design: .rounded, weight: .medium))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
    }
}

struct DeleteButton: View {
    @Binding var showingAlert: Bool
    
    var body: some View {
        Button(role: .destructive) {
            showingAlert = true
        } label: {
            Image(systemName: "trash.circle.fill")
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Theme.dangerColor)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text(title)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
    }
}

struct WeeklyProgressView: View {
    let habit: Habit
    
    var body: some View {
        HStack {
            ForEach(weekDates(), id: \.self) { date in
                VStack(spacing: 8) {
                    Circle()
                        .fill(circleColor(for: date))
                        .frame(width: 32, height: 32)
                        .overlay {
                            if habit.isDateCompleted(date) {
                                Image(systemName: "checkmark")
                                    .font(.system(.callout, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    
                    Text(date.formatted(.dateTime.weekday(.narrow)))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Theme.subtleText)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func weekDates() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        // Find the most recent Monday
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = (weekday + 5) % 7 // Convert Sunday = 1 to Monday = 0
        
        guard let monday = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else {
            return []
        }
        
        // Create array of dates from Monday to Sunday
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: monday)
        }
    }
    
    private func circleColor(for date: Date) -> Color {
        habit.isDateCompleted(date) ? Theme.successColor : Theme.secondaryColor
    }
} 