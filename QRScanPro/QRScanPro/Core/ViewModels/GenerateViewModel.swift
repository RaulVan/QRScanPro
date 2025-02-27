import SwiftUI

class GenerateViewModel: ObservableObject {
    @Published var generatedContent: String?
    @Published var showResult = false
    @Published var currentType: QRCodeType?
    
    func generateQRCode(_ content: String, type: QRCodeType) {
        generatedContent = content
        currentType = type
        showResult = true
    }
    
    func reset() {
        generatedContent = nil
        currentType = nil
        showResult = false
    }
} 