//
//  ContentView.swift
//  RandomApp
//
//  Created by Umar Bhaiyat on 27/11/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var habitStore = HabitStore()
    @State private var showingAddHabit = false
    
    var completedHabitsCount: Int {
        habitStore.habits.filter { habit in
            if habit.goal != nil {
                // For habits with goals, only count if goal is reached
                return habit.isCompletedToday()
            } else {
                // For habits without goals, count any completion
                return habit.isCompletedToday()
            }
        }.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header Stats
                    HStack(spacing: 16) {
                        StatBox(
                            title: "Active",
                            value: "\(habitStore.habits.count)",
                            icon: "list.bullet",
                            gradient: [Color(hex: "6366F1"), Color(hex: "8B5CF6")]
                        )
                        
                        StatBox(
                            title: "Completed",
                            value: "\(completedHabitsCount)",
                            icon: "checkmark.circle.fill",
                            gradient: [Color(hex: "10B981"), Color(hex: "059669")]
                        )
                    }
                    .padding(.horizontal)
                    
                    // Habits List
                    ForEach(habitStore.habits) { habit in
                        HabitRowView(habit: habit, habitStore: habitStore)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.vertical)
            }
            .background(Theme.background)
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Theme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(habitStore: habitStore)
            }
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                Spacer()
                Text(value)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .background(
            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
        .frame(maxWidth: .infinity)
    }
}

struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var habitStore: HabitStore
    
    var goalProgress: (completed: Int, total: Int)? {
        guard let goal = habit.goal else { return nil }
        let completedToday = habitStore.getTodayCompletions(habit)
        return (completedToday, goal)
    }
    
    var body: some View {
        NavigationLink {
            HabitDetailView(habit: habit, habitStore: habitStore)
        } label: {
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    // Icon Circle
                    Circle()
                        .fill(Theme.primaryGradient)
                        .frame(width: 44, height: 44)
                        .overlay {
                            Text(habit.icon)
                                .font(.system(size: 24))
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.title)
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(Theme.textColor)
                        
                        let streak = habit.currentStreak()
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .imageScale(.small)
                                .foregroundStyle(Theme.accentColor)
                            Text("\(streak.count) \(streak.unit)\(streak.count == 1 ? "" : "s") streak")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(Theme.subtleText)
                        }
                    }
                    
                    Spacer()
                    
                    if let progress = goalProgress {
                        if progress.completed >= progress.total {
                            // Show completion checkmark
                            Circle()
                                .fill(Theme.successColor)
                                .frame(width: 32, height: 32)
                                .overlay {
                                    Image(systemName: "checkmark")
                                        .font(.system(.callout, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                        } else {
                            // Show increment button with count
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    habitStore.toggleHabitCompletion(habit)
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text("\(progress.completed)/\(progress.total)")
                                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                                    Image(systemName: "plus.circle.fill")
                                        .imageScale(.medium)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Theme.secondaryColor)
                                .foregroundStyle(Theme.primaryColor)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        // Simple completion toggle for habits without goals
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                habitStore.toggleHabitCompletion(habit)
                            }
                        }) {
                            Circle()
                                .fill(habit.isCompletedToday() ? Theme.successColor : Theme.secondaryColor)
                                .frame(width: 32, height: 32)
                                .overlay {
                                    if habit.isCompletedToday() {
                                        Image(systemName: "checkmark")
                                            .font(.system(.callout, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Goal Progress Bar
                if let progress = goalProgress {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Theme.secondaryColor)
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: progress.completed >= progress.total ?
                                            [Theme.successColor, Theme.successColor.opacity(0.8)] :
                                            [Theme.primaryColor, Theme.gradientEnd],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: min(
                                        geometry.size.width * CGFloat(progress.completed) / CGFloat(progress.total),
                                        geometry.size.width
                                    ),
                                    height: 4
                                )
                        }
                    }
                    .frame(height: 4)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: progress.completed)
                }
            }
            .padding(Theme.padding)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
