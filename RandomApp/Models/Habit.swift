import Foundation

struct Habit: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var frequency: Frequency
    var completedDates: Set<Date>
    var reminderTime: Date?
    var createdAt: Date
    var goal: Int?
    var category: Category
    var selectedDays: Set<Weekday>
    var icon: String
    
    enum Frequency: String, Codable {
        case daily
        case weekly
        case custom
        
        var description: String {
            switch self {
            case .daily: return "Daily"
            case .weekly: return "Weekly"
            case .custom: return "Custom"
            }
        }
    }
    
    enum Category: String, Codable, CaseIterable {
        case health
        case productivity
        case learning
        case mindfulness
        case fitness
        case other
        
        var icon: String {
            switch self {
            case .health: return "heart.fill"
            case .productivity: return "briefcase.fill"
            case .learning: return "book.fill"
            case .mindfulness: return "brain.head.profile"
            case .fitness: return "figure.run"
            case .other: return "star.fill"
            }
        }
        
        var color: [String] {
            switch self {
            case .health: return ["FF6B6B", "EE5253"]
            case .productivity: return ["4834D4", "686DE0"]
            case .learning: return ["22A699", "147D6F"]
            case .mindfulness: return ["BE9FE1", "9B72CF"]
            case .fitness: return ["FF9F43", "EE5A24"]
            case .other: return ["6366F1", "8B5CF6"]
            }
        }
    }
    
    enum Weekday: Int, Codable, CaseIterable {
        case sunday = 1
        case monday = 2
        case tuesday = 3
        case wednesday = 4
        case thursday = 5
        case friday = 6
        case saturday = 7
        
        var shortName: String {
            switch self {
            case .sunday: return "Sun"
            case .monday: return "Mon"
            case .tuesday: return "Tue"
            case .wednesday: return "Wed"
            case .thursday: return "Thu"
            case .friday: return "Fri"
            case .saturday: return "Sat"
            }
        }
    }
    
    init(id: UUID = UUID(), 
         title: String, 
         description: String = "", 
         frequency: Frequency = .daily,
         reminderTime: Date? = nil,
         goal: Int? = nil,
         category: Category = .other,
         selectedDays: Set<Weekday> = [],
         icon: String = "🎯") {
        self.id = id
        self.title = title
        self.description = description
        self.frequency = frequency
        self.completedDates = []
        self.reminderTime = reminderTime
        self.createdAt = Date()
        self.goal = goal
        self.category = category
        self.selectedDays = frequency == .custom ? selectedDays : []
        self.icon = icon
    }
    
    func isCompletedToday() -> Bool {
        return isDateCompleted(Date())
    }
    
    func isDateCompleted(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let completionsForDate = completedDates.filter { calendar.isDate($0, inSameDayAs: date) }.count
        
        if let goal = goal {
            return completionsForDate >= goal
        }
        return completionsForDate > 0
    }
    
    func currentStreak() -> (count: Int, unit: String) {
        let calendar = Calendar.current
        var currentDate = Date()
        var streak = 0
        
        switch frequency {
        case .daily:
            while true {
                if !isDateCompleted(currentDate) {
                    break
                }
                
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            }
            return (streak, "day")
            
        case .weekly, .custom:
            // Get start of current week
            guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)) else {
                return (0, "week")
            }
            
            var currentWeekStart = weekStart
            
            while true {
                let weekEnd = calendar.date(byAdding: .day, value: 7, to: currentWeekStart) ?? currentWeekStart
                var isWeekCompleted = false
                
                // Check each day in the week
                var checkDate = currentWeekStart
                while checkDate < weekEnd {
                    if isDateCompleted(checkDate) {
                        isWeekCompleted = true
                        break
                    }
                    checkDate = calendar.date(byAdding: .day, value: 1, to: checkDate) ?? checkDate
                }
                
                if !isWeekCompleted {
                    break
                }
                
                streak += 1
                currentWeekStart = calendar.date(byAdding: .day, value: -7, to: currentWeekStart) ?? currentWeekStart
            }
            return (streak, "week")
        }
    }
    
    func completionRate(for days: Int) -> Double {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: endDate) else {
            return 0
        }
        
        var completedCount = 0
        var currentDate = startDate
        
        while currentDate <= endDate {
            if isDateCompleted(currentDate) {
                completedCount += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return Double(completedCount) / Double(days)
    }
    
    func longestStreak() -> Int {
        let calendar = Calendar.current
        let sortedDates = completedDates.sorted()
        var longestStreak = 0
        var currentStreak = 0
        var previousDate: Date?
        
        for date in sortedDates {
            if let previous = previousDate {
                let dayDifference = calendar.dateComponents([.day], from: previous, to: date).day ?? 0
                if dayDifference == 1 {
                    currentStreak += 1
                    longestStreak = max(longestStreak, currentStreak)
                } else {
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            previousDate = date
        }
        
        return max(longestStreak, currentStreak)
    }
    
    func completionsByWeekday() -> [Int: Int] {
        let calendar = Calendar.current
        var counts: [Int: Int] = [:]
        
        // Group dates by weekday
        for date in completedDates {
            let weekday = calendar.component(.weekday, from: date)
            
            // Only count if the goal was met for that day
            if isDateCompleted(date) {
                counts[weekday, default: 0] += 1
            }
        }
        
        return counts
    }
    
    func monthlyProgress() -> [(month: Date, completion: Double)] {
        let calendar = Calendar.current
        let now = Date()
        let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        
        var results: [(month: Date, completion: Double)] = []
        var currentDate = sixMonthsAgo
        
        while currentDate <= now {
            guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
                  let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart),
                  let daysInMonth = calendar.dateComponents([.day], from: monthStart, to: nextMonth).day
            else { continue }
            
            let completionsInMonth = completedDates.filter { date in
                calendar.isDate(date, equalTo: currentDate, toGranularity: .month)
            }.count
            
            let completion = Double(completionsInMonth) / Double(daysInMonth)
            results.append((month: monthStart, completion: completion))
            
            currentDate = nextMonth
        }
        
        return results
    }
} 