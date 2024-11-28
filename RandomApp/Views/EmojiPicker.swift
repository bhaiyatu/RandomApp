import SwiftUI

struct EmojiPicker: View {
    @Binding var selectedEmoji: String
    @State private var searchText = ""
    
    // Common emojis for habits
    let emojiCategories: [(String, [String])] = [
        ("Favorites", ["🎯", "⭐️", "✨", "💪", "🏃", "📚", "💭", "🎨", "🎵", "🧘‍♂️"]),
        ("Activities", ["🏃", "🚶", "🏋️", "🧘‍♂️", "🚴", "🎨", "📚", "✍️", "🎵", "🎮", "💻", "📱"]),
        ("Health", ["💪", "🧘‍♂️", "🏃", "💊", "🫁", "💧", "🥗", "🥦", "🍎", "😴"]),
        ("Mind", ["🧠", "📚", "✍️", "💭", "🎯", "⭐️", "✨", "🌟", "💡", "🎨"]),
        ("Time", ["⏰", "⌚️", "📅", "🕐", "⏱", "📆", "🗓", "🌅", "🌙", "✨"]),
        ("Nature", ["🌱", "🌿", "🍀", "🌺", "🌸", "🌼", "🌻", "🌳", "🌲", "🍃"])
    ]
    
    var filteredEmojis: [(String, [String])] {
        if searchText.isEmpty {
            return emojiCategories
        }
        return emojiCategories.compactMap { category, emojis in
            let filtered = emojis.filter { $0.contains(searchText) }
            return filtered.isEmpty ? nil : (category, filtered)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Search bar
            TextField("Search emoji", text: $searchText)
                .textFieldStyle(.plain)
                .padding()
                .background(Theme.secondaryColor)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(filteredEmojis, id: \.0) { category, emojis in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(Theme.subtleText)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(emojis, id: \.self) { emoji in
                                    Button {
                                        selectedEmoji = emoji
                                    } label: {
                                        Text(emoji)
                                            .font(.system(size: 32))
                                    }
                                    .buttonStyle(.plain)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                            .fill(selectedEmoji == emoji ? 
                                                  Theme.primaryColor.opacity(0.2) : 
                                                  Color.clear)
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
    }
} 