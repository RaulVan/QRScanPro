import SwiftUI

struct QRCodeOverlayView: View {
    let codes: [QRCodeResult]
    let onSelect: (QRCodeResult) -> Void
    
    var body: some View {
        ZStack {
            // 绘制所有二维码的边框和选择按钮
            ForEach(codes) { code in
                QRCodeHighlight(code: code, onSelect: onSelect)
            }
        }
    }
}

struct QRCodeHighlight: View {
    let code: QRCodeResult
    let onSelect: (QRCodeResult) -> Void
    @State private var isPressed = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 二维码边框
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green, lineWidth: 2)
                .frame(width: code.bounds.width, height: code.bounds.height)
                .position(x: code.bounds.midX, y: code.bounds.midY)
            
            // 选择按钮
            Button(action: { onSelect(code) }) {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: code.type.icon)
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                }
            }
            .offset(x: 15, y: -15)
            .position(x: code.bounds.maxX, y: code.bounds.minY)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}

#Preview {
    QRCodeOverlayView(codes: [
        QRCodeResult(content: "https://example.com", bounds: CGRect(x: 100, y: 100, width: 100, height: 100))
    ]) { _ in }
} 
