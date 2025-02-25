import Foundation

class HistoryManager: ObservableObject {
    @Published private(set) var scannedRecords: [ScanRecord] = []
    @Published private(set) var generatedRecords: [ScanRecord] = []
    
    private let scannedRecordsKey = "scanned_records"
    private let generatedRecordsKey = "generated_records"
    
    init() {
        loadRecords()
    }
    
    func addScannedRecord(_ content: String) {
        let record = ScanRecord(content: content)
        scannedRecords.insert(record, at: 0)
        saveRecords()
    }
    
    func addGeneratedRecord(_ content: String) {
        let record = ScanRecord(content: content)
        generatedRecords.insert(record, at: 0)
        saveRecords()
    }
    
    func clearScannedRecords() {
        scannedRecords.removeAll()
        saveRecords()
    }
    
    func clearGeneratedRecords() {
        generatedRecords.removeAll()
        saveRecords()
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: scannedRecordsKey),
           let records = try? JSONDecoder().decode([ScanRecord].self, from: data) {
            scannedRecords = records
        }
        
        if let data = UserDefaults.standard.data(forKey: generatedRecordsKey),
           let records = try? JSONDecoder().decode([ScanRecord].self, from: data) {
            generatedRecords = records
        }
    }
    
    private func saveRecords() {
        if let data = try? JSONEncoder().encode(scannedRecords) {
            UserDefaults.standard.set(data, forKey: scannedRecordsKey)
        }
        
        if let data = try? JSONEncoder().encode(generatedRecords) {
            UserDefaults.standard.set(data, forKey: generatedRecordsKey)
        }
    }
} 