import Foundation

enum SubscriptionPlan: Equatable {
    case trial
    case monthly
    case quarterly
    
    var title: String {
        switch self {
        case .trial:
            return "3 days trial"
        case .monthly:
            return "1 Month"
        case .quarterly:
            return "3 Months"
        }
    }
    
    var price: Double {
        switch self {
        case .trial:
            return 9.0
        case .monthly:
            return 19.0
        case .quarterly:
            return 29.0
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
        }
    }
    
    var productId: String {
        switch self {
        case .trial:
            return "com.qrscanpro.subscription.trial"
        case .monthly:
            return "com.qrscanpro.subscription.monthly"
        case .quarterly:
            return "com.qrscanpro.subscription.quarterly"
        }
    }
    
    var features: [String] {
        return [
            "Advanced analytics on your codes",
            "Unlimited Exports & Folders",
            "Batch Scan & Pin",
            "Protect Custom QR Codes",
            "NO Ads"
        ]
    }
    
    static var defaultPlan: SubscriptionPlan {
        return .quarterly // 设置默认选中的计划
    }
} 