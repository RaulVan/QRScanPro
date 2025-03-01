import Foundation

enum SubscriptionPlan: Equatable {
    case trial
    case monthly
    case quarterly
    case yearly
    
    var title: String {
        switch self {
        case .trial:
            return "3 days trial"
        case .monthly:
            return "1 Month"
        case .quarterly:
            return "3 Months"
        case .yearly:
            return "12 Months"
        }
    }
    
    var price: Double {
        switch self {
        case .trial:
            return 0.0
        case .monthly:
            return 0.99
        case .quarterly:
            return 3.99
        case .yearly:
            return 10.99
        }
    }
    
    var priceDescription: String {
        return "$\(String(format: "%.2f", price)) per month"
    }
    
    var duration: Int {
        switch self {
        case .trial:
            return 3 // days
        case .monthly:
            return 30 // days
        case .quarterly:
            return 90 // days
        case .yearly:
            return 365 // days
        }
    }
    
    var productId: String {
        switch self {
        case .trial:
            return "com.qrscanpro.subscription.trial"
        case .monthly:
            return "com.qrscanpro.subscription.monthly1"
        case .quarterly:
            return "com.qrscanpro.subscription.quarterly"
        case .yearly:
            return "com.qrscanpro.subscription.yearly"
        }
    }
    
    var features: [String] {
        return [
            "Advanced analytics on your codes",
//            "Unlimited Exports & Folders",
//            "Batch Scan & Pin",
            "Protect Custom QR Codes",
            "NO Ads"
        ]
    }
    
    static var defaultPlan: SubscriptionPlan {
        return .monthly // 设置默认选中的计划
    }
    
    static var productIds: [String] {
        //SubscriptionPlan.trial.productId,
        return [SubscriptionPlan.monthly.productId, SubscriptionPlan.quarterly.productId, SubscriptionPlan.yearly.productId]
    }
}
