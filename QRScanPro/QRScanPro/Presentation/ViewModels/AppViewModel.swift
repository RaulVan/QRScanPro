import SwiftUI
import Combine
import StoreKit

class AppViewModel: ObservableObject {
    @Published var scanHistory: [ScanItem] = []
    @Published var generatedHistory: [GeneratedItem] = []
    @Published var isSubscribed = false
    @Published var showSubscription = false
    @Published var products: [Product] = []
//    @Published var purchaseError: String?
    
    private var subscriptionStatusTask: Task<Void, Error>?
    private var productsTask: Task<Void, Error>?
    private var updates: Task<Void, Error>?
    
    init() {
        // 从 UserDefaults 加载订阅状态
        isSubscribed = UserDefaults.standard.bool(forKey: "isSubscribed")
        
        // 开始监听订阅状态更新
        updates = observeTransactionUpdates()
        // 获取产品信息
        productsTask = requestProducts()
        // 验证订阅状态
        subscriptionStatusTask = checkSubscriptionStatus()
    }
    
    deinit {
        subscriptionStatusTask?.cancel()
        productsTask?.cancel()
        updates?.cancel()
    }
    
    // MARK: - Subscription
    func subscribe(to plan: SubscriptionPlan) async throws {
        // 检查产品列表是否已加载
        if products.isEmpty {
            // 重新请求产品信息
            do {
                _ = await requestProducts() // 等待产品加载完成
            } catch {
                // 如果产品加载失败，抛出错误
                throw SubscriptionError.productLoadingFailed
            }
        }
//        else {
//            products.forEach { p in
//                print(p.id)
//            }
//        }
        // 查找对应的产品
        guard let product = products.first(where: { $0.id == plan.productId }) else {
            throw SubscriptionError.productNotFound
        }

        do {
            // 发起购买
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // 验证购买凭证
                switch verification {
                case .verified(let transaction):
                    // 购买成功，更新订阅状态
                    await updateSubscriptionStatus(true)
                    await transaction.finish()
                case .unverified:
                    throw SubscriptionError.verificationFailed
                }
            case .userCancelled:
                throw SubscriptionError.userCancelled
            case .pending:
                throw SubscriptionError.pending
            @unknown default:
                throw SubscriptionError.unknown
            }
        } catch {
            await updateSubscriptionStatus(false)
            throw error
        }
    }
    
    func restorePurchases() async throws {
        // 检查所有交易
        do {
            var restored = false // 添加一个标志来跟踪是否恢复了购买
            for await result in Transaction.currentEntitlements {
                restored = true // 如果循环执行，则表示找到了交易
                switch result {
                case .verified(let transaction):
                    // 验证成功，更新订阅状态
                    print("Restore Purchase: Transaction verified")
                    await updateSubscriptionStatus(true)
                    await transaction.finish()
                case .unverified:
                    print("Restore Purchase: Transaction not verified")
                    throw SubscriptionError.verificationFailed
                }
            }
            if !restored { // 检查是否找到了任何交易
                print("Restore Purchase: No purchases to restore")
                throw SubscriptionError.restoreNoPurchases
            } else {
                
            }
        } catch {
            print("Restore Purchase Failed: \(error)")
            throw SubscriptionError.restoreError
        }
    }
    
    // MARK: - Private Methods
    private func requestProducts() -> Task<Void, Error> {
        Task {
            do {
                // 获取所有订阅计划的产品 ID
                let productIds = Set(SubscriptionPlan.productIds)
                
                // 请求产品信息
                let products = try await Product.products(for: productIds)
                await MainActor.run {
                    self.products = products
                }
            } catch {
                print("Failed to load products: \(error)")
            }
        }
    }
    
    private func checkSubscriptionStatus() -> Task<Void, Error> {
        Task {
            for await result in Transaction.currentEntitlements {
                switch result {
                case .verified(let transaction):
                    // 检查订阅是否过期
                    if let expirationDate = transaction.expirationDate,
                       expirationDate > Date() {
                        await updateSubscriptionStatus(true)
                    } else {
                        await updateSubscriptionStatus(false)
                    }
                case .unverified:
                    await updateSubscriptionStatus(false)
                }
            }
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Error> {
        Task {
            for await verification in Transaction.updates {
                switch verification {
                case .verified(let transaction):
                    // 处理交易更新
                    if let expirationDate = transaction.expirationDate,
                       expirationDate > Date() {
                        await updateSubscriptionStatus(true)
                    } else {
                        await updateSubscriptionStatus(false)
                    }
                    await transaction.finish()
                case .unverified:
                    await updateSubscriptionStatus(false)
                }
            }
        }
    }
    
    @MainActor
    private func updateSubscriptionStatus(_ isSubscribed: Bool) {
        self.isSubscribed = isSubscribed
        UserDefaults.standard.set(isSubscribed, forKey: "isSubscribed")
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

// MARK: - Subscription Errors
enum SubscriptionError: LocalizedError {
    case productNotFound
    case purchaseFailed
    case verificationFailed
    case userCancelled
    case pending
    case unknown
    case productLoadingFailed
    case restoreNoPurchases
    case restoreError
    case restoreCompleted
    
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        case .verificationFailed:
            return "Purchase verification failed"
        case .userCancelled:
            return "Purchase cancelled"
        case .pending:
            return "Purchase is pending"
        case .unknown:
            return "An unknown error occurred"
        case .productLoadingFailed:
            return "Failed to load product list"
        case .restoreNoPurchases:
            return "Restore Purchase: No purchases to restore"
        case .restoreError:
            return "Restore Purchase Failed"
        case .restoreCompleted:
            return "Restore Purchase: Completed"
        }
    }
} 
