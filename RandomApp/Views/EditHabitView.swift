import SwiftUI

struct EditHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var habitStore: HabitStore
    
    let habit: Habit
    @State private var title: String
    @State private var description: String
    @State private var frequency: Habit.Frequency
    @State private var enableReminder: Bool
    @State private var reminderTime: Date
    @State private var category: Habit.Category
    @State private var goal: String
    @State private var selectedDays: Set<Habit.Weekday>
    @State private var selectedEmoji: String
    @State private var showingEmojiPicker = false
    
    init(habit: Habit, habitStore: HabitStore) {
        self.habit = habit
        self.habitStore = habitStore
        _title = State(initialValue: habit.title)
        _description = State(initialValue: habit.description)
        _frequency = State(initialValue: habit.frequency)
        _enableReminder = State(initialValue: habit.reminderTime != nil)
        _reminderTime = State(initialValue: habit.reminderTime ?? Date())
        _category = State(initialValue: habit.category)
        _goal = State(initialValue: habit.goal?.description ?? "")
        _selectedDays = State(initialValue: habit.selectedDays)
        _selectedEmoji = State(initialValue: habit.icon)
    }
    
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
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveChanges) {
                        Text("Save")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.primaryColor)
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingEmojiPicker) {
                EmojiPicker(selectedEmoji: $selectedEmoji)
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    private func saveChanges() {
        var updatedHabit = habit
        updatedHabit.title = title
        updatedHabit.description = description
        updatedHabit.frequency = frequency
        updatedHabit.reminderTime = enableReminder ? reminderTime : nil
        updatedHabit.goal = Int(goal)
        updatedHabit.category = category
        updatedHabit.selectedDays = frequency == .custom ? selectedDays : []
        updatedHabit.icon = selectedEmoji
        
        withAnimation {
            habitStore.updateHabit(updatedHabit)
        }
        dismiss()
    }
} 