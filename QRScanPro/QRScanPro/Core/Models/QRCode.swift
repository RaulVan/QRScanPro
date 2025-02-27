import Foundation
import CoreGraphics
import AVFoundation
import SwiftUI

struct QRCodeResult: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let bounds: CGRect
    var type: QRCodeType {
        QRCodeType.detect(from: content)
    }
    
    static func == (lhs: QRCodeResult, rhs: QRCodeResult) -> Bool {
        return lhs.content == rhs.content
    }
}

struct ScanRecord: Identifiable, Codable {
    let id: UUID
    let content: String
    let type: QRCodeType
    let timestamp: Date
    
    init(id: UUID = UUID(), content: String, type: QRCodeType? = nil, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.type = type ?? QRCodeType.detect(from: content)
        self.timestamp = timestamp
    }
}

enum QRCodeType: String, Codable, Identifiable, CaseIterable {
    case url
    case email
    case phone
    case text
    case wifi
    case contact
    
    case message
    case clipboard
    case location
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .url: return "safari"
        case .email: return "envelope.fill"
        case .phone: return "phone.fill"
        case .text: return "text.bubble.fill"
        case .wifi: return "wifi"
        case .contact: return "person.crop.circle.fill"
        case .message: return "message.fill"
        case .clipboard: return "doc.on.clipboard"
        case .location: return "location.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .url: return .blue
        case .email: return .pink
        case .phone: return .green
        case .text: return .purple
        case .wifi: return .red
        case .contact: return .orange
        case .message: return .purple
        case .clipboard: return .cyan
        case .location: return .yellow
        }
    }
    
    var title: String {
        switch self {
        case .url: return "Website URL"
        case .email: return "Email"
        case .phone: return "Phone Number"
        case .text: return "Text"
        case .wifi: return "WiFi"
        case .contact: return "Contact"
        case .message: return "Message"
        case .clipboard: return "Clipboard URL"
        case .location: return "Location"
        }
    }
    
    static func detect(from content: String) -> QRCodeType {
        if content.hasPrefix("http://") || content.hasPrefix("https://") {
            return .url
        } else if content.contains("@") || content.hasPrefix("mailto:") {
            return .email
        } else if content.hasPrefix("tel:") || isPhoneNumber(content) {
            return .phone
        } else if content.hasPrefix("WIFI:") {
            return .wifi
        } else if content.hasPrefix("BEGIN:VCARD") {
            return .contact
        } else if content.hasPrefix("sms:") {
            return .message
        } else if content.hasPrefix("geo:") {
            return .location
        } else {
            return .text
        }
    }
    
    private static func isPhoneNumber(_ string: String) -> Bool {
        let pattern = "^\\d{10,}$"
        let cleanString = string.replacingOccurrences(of: " ", with: "")
                                .replacingOccurrences(of: "-", with: "")
                                .replacingOccurrences(of: "(", with: "")
                                .replacingOccurrences(of: ")", with: "")
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        
        let range = NSRange(location: 0, length: cleanString.utf16.count)
        return regex.firstMatch(in: cleanString, range: range) != nil
    }
}
