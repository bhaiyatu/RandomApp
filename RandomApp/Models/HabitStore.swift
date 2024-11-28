import Foundation

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
    
    private let saveKey = "SavedHabits"
    
    init() {
        loadHabits()
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
        }
    }
    
    func toggleHabitCompletion(_ habit: Habit) {
        if var updatedHabit = habits.first(where: { $0.id == habit.id }) {
            let calendar = Calendar.current
            let today = Date()
            
            // Count today's completions
            let todayCompletions = updatedHabit.completedDates.filter({ date in
                calendar.isDate(date, inSameDayAs: today)
            }).count
            
            // If we haven't reached the goal, add another completion
            if let goal = updatedHabit.goal, todayCompletions < goal {
                updatedHabit.completedDates.insert(today)
                updateHabit(updatedHabit)
            } else if updatedHabit.goal == nil {
                // If no goal is set, toggle as before
                if updatedHabit.isCompletedToday() {
                    updatedHabit.completedDates = updatedHabit.completedDates.filter({ date in
                        !calendar.isDate(date, inSameDayAs: today)
                    })
                } else {
                    updatedHabit.completedDates.insert(today)
                }
                updateHabit(updatedHabit)
            }
        }
    }
    
    func decrementHabitCompletion(_ habit: Habit) {
        if var updatedHabit = habits.first(where: { $0.id == habit.id }) {
            let calendar = Calendar.current
            let today = Date()
            
            // Get today's completions sorted by time
            let todayCompletions = updatedHabit.completedDates.filter({ date in
                calendar.isDate(date, inSameDayAs: today)
            }).sorted()
            
            // Remove the most recent completion if any exist
            if let lastCompletion = todayCompletions.last {
                updatedHabit.completedDates.remove(lastCompletion)
                updateHabit(updatedHabit)
            }
        }
    }
    
    func getTodayCompletions(_ habit: Habit) -> Int {
        let calendar = Calendar.current
        let today = Date()
        
        return habit.completedDates.filter({ date in
            calendar.isDate(date, inSameDayAs: today)
        }).count
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
    }
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
} 
