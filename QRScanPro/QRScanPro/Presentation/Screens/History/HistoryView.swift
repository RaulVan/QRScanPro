import SwiftUI

struct HistoryView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom segmented control
                CustomSegmentedControl(selectedTab: $selectedTab)
                    .padding()
                
                if selectedTab == 0 {
                    ScannedHistoryList()
                } else {
                    GeneratedHistoryList()
                }
            }
            .navigationTitle("History")
        }
    }
}

struct CustomSegmentedControl: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            SegmentButton(title: "Scanned", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            SegmentButton(title: "Generated", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
        .frame(height: 40)
    }
}

struct SegmentButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color.purple)
                                .shadow(radius: 2)
                        }
                    }
                )
        }
        .padding(.horizontal, 2)
    }
}

struct ScannedHistoryList: View {
    var body: some View {
        List {
            Section(header: Text("Today")) {
                HistoryItem(icon: "envelope.fill", title: "Email", subtitle: "brad.wheeler@example.com", color: .pink)
                HistoryItem(icon: "person.crop.circle.fill", title: "Contact", subtitle: "Marvin Williamson", color: .orange)
            }
            
            Section(header: Text("Yesterday")) {
                HistoryItem(icon: "phone.fill", title: "Phone", subtitle: "(702) 555-0122", color: .green)
                HistoryItem(icon: "globe", title: "Website", subtitle: "http://www.example.com", color: .blue)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct GeneratedHistoryList: View {
    var body: some View {
        List {
            Section(header: Text("Recent")) {
                HistoryItem(icon: "wifi", title: "WiFi", subtitle: "Home Network", color: .red)
                HistoryItem(icon: "message.fill", title: "Message", subtitle: "Meeting at 3 PM", color: .purple)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct HistoryItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView()
} 