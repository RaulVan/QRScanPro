import Foundation
import CoreGraphics

struct QRCodeResult: Identifiable {
    let id = UUID()
    let content: String
    let bounds: CGRect
    var type: QRCodeType
    
    enum QRCodeType {
        case url
        case text
        case email
        case phone
        case other
        
        var icon: String {
            switch self {
            case .url: return "link"
            case .text: return "doc.text"
            case .email: return "envelope"
            case .phone: return "phone"
            case .other: return "questionmark"
            }
        }
    }
    
    init(content: String, bounds: CGRect) {
        self.content = content
        self.bounds = bounds
        
        // 根据内容判断类型
        if content.lowercased().hasPrefix("http") || content.lowercased().hasPrefix("https") {
            self.type = .url
        } else if content.contains("@") {
            self.type = .email
        } else if content.replacingOccurrences(of: " ", with: "").matches(of: /^\+?[\d\-\(\)]+$/).count > 0 {
            self.type = .phone
        } else {
            self.type = .text
        }
    }
} 