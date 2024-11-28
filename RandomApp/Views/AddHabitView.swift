import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var habitStore: HabitStore
    
    @State private var title = ""
    @State private var description = ""
    @State private var frequency: Habit.Frequency = .daily
    @State private var enableReminder = false
    @State private var reminderTime = Date()
    @State private var category: Habit.Category = .other
    @State private var goal: String = ""
    @State private var selectedDays: Set<Habit.Weekday> = []
    @State private var selectedEmoji = "🎯"
    @State private var showingEmojiPicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(icon: "square.text.square.fill", title: "Habit Details")
                        
                        VStack(spacing: 20) {
                            // Emoji Selector
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "face.smiling")
                                        .foregroundStyle(Theme.primaryColor)
                                    Text("Icon")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundStyle(Theme.subtleText)
                                }
                                
                                Button {
                                    showingEmojiPicker = true
                                } label: {
                                    HStack {
                                        Text(selectedEmoji)
                                            .font(.system(size: 32))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(Theme.subtleText)
                                    }
                                    .padding()
                                    .background(Theme.secondaryColor)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                                }
                                .buttonStyle(.plain)
                            }
                            
                            CustomTextField(
                                title: "Title",
                                text: $title,
                                icon: "pencil.line",
                                placeholder: "Enter habit name"
                            )
                            
                            CustomTextField(
                                title: "Description",
                                text: $description,
                                icon: "text.alignleft",
                                placeholder: "Add some details"
                            )
                            
                            FrequencySelector(
                                frequency: $frequency,
                                selectedDays: $selectedDays
                            )
                        }
                    }
                    .padding()
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
                    
                    // Category Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(icon: "folder.fill", title: "Category")
                        
                        CategorySelector(selectedCategory: $category)
                    }
                    .padding()
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
                    
                    // Goal Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(icon: "target", title: "Goal")
                        
                        VStack(spacing: 8) {
                            HStack(spacing: 12) {
                                TextField("0", text: $goal)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.plain)
                                    .font(.system(.body, design: .rounded))
                                    .onChange(of: goal) { oldValue, newValue in
                                        // Only allow numeric values
                                        let filtered = newValue.filter { "0123456789".contains($0) }
                                        if filtered != newValue {
                                            goal = filtered
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Theme.secondaryColor)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                                
                                Text("times per")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundStyle(Theme.textColor)
                                
                                Text(frequency == .daily ? "day" : "week")
                                    .font(.system(.body, design: .rounded, weight: .medium))
                                    .foregroundStyle(Theme.primaryColor)
                            }
                            
                            Text("Set how many times you want to complete this habit")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(Theme.subtleText)
                        }
                    }
                    .padding()
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
                    
                    // Reminder Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(icon: "bell.fill", title: "Reminder")
                        
                        VStack(spacing: 16) {
                            ReminderToggle(isOn: $enableReminder)
                            
                            if enableReminder {
                                TimePicker(time: $reminderTime)
                            }
                        }
                    }
                    .padding()
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: addHabit) {
                        Text("Create")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.primaryColor)
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingEmojiPicker) {
                NavigationStack {
                    EmojiPicker(selectedEmoji: $selectedEmoji)
                        .navigationTitle("Choose Icon")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    showingEmojiPicker = false
                                }
                            }
                        }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
    
    private func addHabit() {
        let habit = Habit(
            title: title,
            description: description,
            frequency: frequency,
            reminderTime: enableReminder ? reminderTime : nil,
            goal: Int(goal),
            category: category,
            selectedDays: selectedDays,
            icon: selectedEmoji
        )
        withAnimation {
            habitStore.addHabit(habit)
        }
        dismiss()
    }
}

// MARK: - Supporting Views
struct SectionHeader: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Theme.primaryColor)
            Text(title)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Theme.subtleText)
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(Theme.primaryColor)
                Text(title)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Theme.subtleText)
            }
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(.body, design: .rounded))
                .padding()
                .background(Theme.secondaryColor)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
    }
}

struct FrequencySelector: View {
    @Binding var frequency: Habit.Frequency
    @Binding var selectedDays: Set<Habit.Weekday>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .foregroundStyle(Theme.primaryColor)
                Text("Frequency")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Theme.subtleText)
            }
            
            HStack(spacing: 8) {
                FrequencyButton(
                    title: "Daily",
                    icon: "sun.max.fill",
                    isSelected: frequency == .daily,
                    action: { 
                        frequency = .daily
                        selectedDays = []
                    }
                )
                
                FrequencyButton(
                    title: "Weekly",
                    icon: "calendar.badge.clock",
                    isSelected: frequency == .weekly,
                    action: { 
                        frequency = .weekly
                        selectedDays = []
                    }
                )
                
                FrequencyButton(
                    title: "Custom",
                    icon: "calendar.day.timeline.left",
                    isSelected: frequency == .custom,
                    action: { frequency = .custom }
                )
            }
            
            if frequency == .custom {
                WeekdaySelector(selectedDays: $selectedDays)
            }
        }
    }
}

struct FrequencyButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .imageScale(.small)
                Text(title)
                    .font(.system(.subheadline, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                LinearGradient(
                    colors: isSelected ? 
                        [Theme.gradientStart, Theme.gradientEnd] :
                        [Theme.secondaryColor, Theme.secondaryColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundStyle(isSelected ? .white : Theme.textColor)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}

struct ReminderToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundStyle(Theme.accentColor)
                Text("Enable Daily Reminder")
                    .font(.system(.body, design: .rounded))
            }
        }
        .tint(Theme.primaryColor)
    }
}

struct TimePicker: View {
    @Binding var time: Date
    
    var body: some View {
        DatePicker(
            "Reminder Time",
            selection: $time,
            displayedComponents: .hourAndMinute
        )
        .datePickerStyle(.compact)
        .font(.system(.body, design: .rounded))
        .tint(Theme.primaryColor)
    }
}

// New Supporting View
struct CategorySelector: View {
    @Binding var selectedCategory: Habit.Category
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Habit.Category.allCases, id: \.self) { category in
                CategoryButton(
                    category: category,
                    isSelected: selectedCategory == category,
                    action: { selectedCategory = category }
                )
            }
        }
    }
}

struct CategoryButton: View {
    let category: Habit.Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                Text(category.rawValue.capitalized)
                    .font(.system(.body, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: isSelected ? 
                        [Color(hex: category.color[0]), Color(hex: category.color[1])] :
                        [Theme.secondaryColor, Theme.secondaryColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundStyle(isSelected ? .white : Theme.textColor)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}

struct WeekdaySelector: View {
    @Binding var selectedDays: Set<Habit.Weekday>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Days")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Theme.subtleText)
            
            HStack(spacing: 8) {
                ForEach(Habit.Weekday.allCases, id: \.self) { day in
                    WeekdayButton(
                        day: day,
                        isSelected: selectedDays.contains(day),
                        action: {
                            if selectedDays.contains(day) {
                                selectedDays.remove(day)
                            } else {
                                selectedDays.insert(day)
                            }
                        }
                    )
                }
            }
        }
        .padding(.top, 8)
    }
}

struct WeekdayButton: View {
    let day: Habit.Weekday
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day.shortName)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: isSelected ? 
                            [Theme.gradientStart, Theme.gradientEnd] :
                            [Theme.secondaryColor, Theme.secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundStyle(isSelected ? .white : Theme.textColor)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(.plain)
    }
} 