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
                    ScannedHistoryList(records: historyManager.scannedRecords, selectedRecord: $selectedRecord)
                } else {
                    GeneratedHistoryList(records: historyManager.generatedRecords, selectedRecord: $selectedRecord)
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if selectedTab == 0 {
                            historyManager.clearScannedRecords()
                        } else {
                            historyManager.clearGeneratedRecords()
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
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

struct RecordDetailView: View {
    let record: ScanRecord
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: record.type.icon)
                            .font(.title)
                            .foregroundColor(record.type.color)
                        Text(record.type.rawValue.capitalized)
                            .font(.headline)
                    }
                    
                    Text(record.content)
                        .font(.body)
                }
                .padding(.vertical, 8)
            }
            
            Section {
                HStack {
                    Text("Scanned on")
                    Spacer()
                    Text(record.timestamp, style: .date)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Time")
                    Spacer()
                    Text(record.timestamp, style: .time)
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                Button(action: {
                    UIPasteboard.general.string = record.content
                }) {
                    Label("Copy to Clipboard", systemImage: "doc.on.doc")
                }
                
                if let url = URL(string: record.content), UIApplication.shared.canOpenURL(url) {
                    Button(action: {
                        UIApplication.shared.open(url)
                    }) {
                        Label("Open Link", systemImage: "safari")
                    }
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(HistoryManager())
} 