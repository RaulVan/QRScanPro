import SwiftUI
import Foundation
import UIKit


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
