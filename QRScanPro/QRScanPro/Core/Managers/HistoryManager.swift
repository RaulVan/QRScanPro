import Foundation
import SwiftUI

class HistoryManager: ObservableObject {
    @Published var scannedRecords: [ScanRecord] = []
    @Published var generatedRecords: [ScanRecord] = []
    
    init() {
        loadData()
    }
    
    func addScannedRecord(_ content: String) {
        let record = ScanRecord(content: content, timestamp: Date())
        scannedRecords.insert(record, at: 0)
        saveData()
    }
    
    func addGeneratedRecord(_ content: String) {
        let record = ScanRecord(content: content, timestamp: Date())
        generatedRecords.insert(record, at: 0)
        saveData()
    }
    
    func removeScannedRecord(_ record: ScanRecord) {
        scannedRecords.removeAll { $0.id == record.id }
        saveData()
    }
    
    func removeGeneratedRecord(_ record: ScanRecord) {
        generatedRecords.removeAll { $0.id == record.id }
        saveData()
    }
    
    private func saveData() {
        // 保存到 UserDefaults 或其他存储
        let encoder = JSONEncoder()
        if let scannedData = try? encoder.encode(scannedRecords) {
            UserDefaults.standard.set(scannedData, forKey: "scannedRecords")
        }
        if let generatedData = try? encoder.encode(generatedRecords) {
            UserDefaults.standard.set(generatedData, forKey: "generatedRecords")
        }
    }
    
    private func loadData() {
        // 从 UserDefaults 或其他存储加载
        let decoder = JSONDecoder()
        if let scannedData = UserDefaults.standard.data(forKey: "scannedRecords"),
           let loadedScannedRecords = try? decoder.decode([ScanRecord].self, from: scannedData) {
            scannedRecords = loadedScannedRecords
        }
        if let generatedData = UserDefaults.standard.data(forKey: "generatedRecords"),
           let loadedGeneratedRecords = try? decoder.decode([ScanRecord].self, from: generatedData) {
            generatedRecords = loadedGeneratedRecords
        }
    }
} 