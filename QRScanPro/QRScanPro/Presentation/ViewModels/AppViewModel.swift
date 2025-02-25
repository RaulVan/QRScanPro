import SwiftUI
import Combine
import StoreKit

class AppViewModel: ObservableObject {
    @Published var scanHistory: [ScanItem] = []
    @Published var generatedHistory: [GeneratedItem] = []
    @Published var isSubscribed = false
    @Published var showSubscription = false
    
    init() {
        // 从 UserDefaults 加载订阅状态
        isSubscribed = UserDefaults.standard.bool(forKey: "isSubscribed")
    }
    
    // MARK: - Subscription
    func subscribe(to plan: SubscriptionPlan) {
        // TODO: 实现 StoreKit 订阅购买
        // 这里是模拟订阅成功
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isSubscribed = true
            // 保存订阅状态
            UserDefaults.standard.set(true, forKey: "isSubscribed")
        }
    }
    
    func restorePurchases() {
        // TODO: 实现恢复购买功能
        // 这里是模拟恢复购买
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isSubscribed = true
            UserDefaults.standard.set(true, forKey: "isSubscribed")
        }
    }
    
    // MARK: - Scan Items
    struct ScanItem: Identifiable {
        let id = UUID()
        let type: String
        let content: String
        let date: Date
    }
    
    // MARK: - Generated Items
    struct GeneratedItem: Identifiable {
        let id = UUID()
        let type: String
        let content: String
        let date: Date
    }
    
    // MARK: - Methods
    func addScanItem(_ type: String, content: String) {
        let item = ScanItem(type: type, content: content, date: Date())
        scanHistory.insert(item, at: 0)
    }
    
    func addGeneratedItem(_ type: String, content: String) {
        let item = GeneratedItem(type: type, content: content, date: Date())
        generatedHistory.insert(item, at: 0)
    }
    
    // MARK: - Pro Features
    var canUseProFeatures: Bool {
        return isSubscribed
    }
    
    func checkProAccess() -> Bool {
        if !isSubscribed {
            showSubscription = true
            return false
        }
        return true
    }
} 
