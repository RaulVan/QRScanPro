import SwiftUI

struct HistoryView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var historyManager: HistoryManager
    @State private var selectedRecord: ScanRecord?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom segmented control
                CustomSegmentedControl(selectedTab: $selectedTab)
                    .padding()
                
                if selectedTab == 0 {
                    ScannedHistoryList(records: historyManager.scannedRecords, selectedRecord: $selectedRecord, onDelete: { record in
                        historyManager.removeScannedRecord(record)
                    })
                } else {
                    GeneratedHistoryList(records: historyManager.generatedRecords, selectedRecord: $selectedRecord, onDelete: { record in
                        historyManager.removeGeneratedRecord(record)
                    })
                }
            }
            .navigationTitle("History")
            .sheet(item: $selectedRecord) { record in
                NavigationView {
                    RecordDetailView(record: record)
                }
            }
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
    let records: [ScanRecord]
    @Binding var selectedRecord: ScanRecord?
    let onDelete: (ScanRecord) -> Void
    
    var groupedRecords: [(String, [ScanRecord])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: records) { record in
            if calendar.isDateInToday(record.timestamp) {
                return "Today"
            } else if calendar.isDateInYesterday(record.timestamp) {
                return "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy"
                return formatter.string(from: record.timestamp)
            }
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        List {
            ForEach(groupedRecords, id: \.0) { section in
                Section(header: Text(section.0)) {
                    ForEach(section.1) { record in
                        HistoryItem(
                            icon: record.type.icon,
                            title: record.type.rawValue.capitalized,
                            subtitle: record.content,
                            color: record.type.color
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedRecord = record
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                onDelete(record)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct GeneratedHistoryList: View {
    let records: [ScanRecord]
    @Binding var selectedRecord: ScanRecord?
    let onDelete: (ScanRecord) -> Void
    
    var groupedRecords: [(String, [ScanRecord])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: records) { record in
            if calendar.isDateInToday(record.timestamp) {
                return "Today"
            } else if calendar.isDateInYesterday(record.timestamp) {
                return "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy"
                return formatter.string(from: record.timestamp)
            }
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        List {
            ForEach(groupedRecords, id: \.0) { section in
                Section(header: Text(section.0)) {
                    ForEach(section.1) { record in
                        HistoryItem(
                            icon: record.type.icon,
                            title: record.type.rawValue.capitalized,
                            subtitle: record.content,
                            color: record.type.color
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedRecord = record
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                onDelete(record)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
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
        .environmentObject(HistoryManager())
} 