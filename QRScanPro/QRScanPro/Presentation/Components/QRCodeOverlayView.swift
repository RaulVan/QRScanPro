import SwiftUI

struct QRCodeOverlayView: View {
    let codes: [QRCodeResult]
    let onSelect: (QRCodeResult) -> Void
    
    var body: some View {
        // 每个二维码单独处理，不使用ZStack叠放，避免点击事件穿透问题
        GeometryReader { geometry in
            ZStack {
                // 绘制所有二维码的边框和选择按钮
                ForEach(codes) { code in
                    QRCodeItem(code: code, onSelect: onSelect)
                        .zIndex(10) // 确保二维码项目在背景之上
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .allowsHitTesting(true) // 确保整个覆盖层可以接收点击
            .onAppear {
                print("二维码覆盖层出现 - 二维码数量: \(codes.count)")
                for (index, code) in codes.enumerated() {
                    print("覆盖层展示二维码[\(index)]: \(code.content), 位置: \(code.bounds)")
                }
            }
        }
    }
}

// 单个二维码项目组件
struct QRCodeItem: View {
    let code: QRCodeResult
    let onSelect: (QRCodeResult) -> Void
    @State private var isPressed = false
    
    // 垂直偏移量
    private let verticalOffset: CGFloat = -40
    
    // 扩大触摸区域边距
    private let touchPadding: CGFloat = 30
    
    // 计算实际框架尺寸
    private var frameWidth: CGFloat {
        max(code.bounds.width, 100) + touchPadding
    }
    
    private var frameHeight: CGFloat {
        max(code.bounds.height, 100) + touchPadding
    }
    
    var body: some View {
        // 使用Button替代ZStack+onTapGesture
        Button(action: {
            print("Button直接点击二维码: \(code.content)")
            handleTap()
        }) {
            ZStack {
                // 半透明背景
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(isPressed ? 0.3 : 0.2))
                    .frame(width: frameWidth, height: frameHeight)
                
                // 边框
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green, lineWidth: isPressed ? 4 : 3)
                    .frame(width: frameWidth, height: frameHeight)
                
                // 类型图标
                VStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 2) {
                            ZStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 26, height: 26)
                                
                                Image(systemName: code.type.icon)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                            }
                            
                            // 添加"open"文字标签
                            Text("open")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.green)
                                )
                        }
                        .padding(8)
                    }
                    Spacer()
                }
                .frame(width: frameWidth, height: frameHeight)
            }
        }
        .buttonStyle(QRCodeButtonStyle(isPressed: isPressed))
        .contentShape(Rectangle()) // 确保整个区域可点击
        // 定位每个二维码框的位置
        .position(x: code.bounds.midX, y: code.bounds.midY + verticalOffset)
        // 明确标记每个二维码的区域范围，避免点击冲突
        .id("qrcode-\(code.id)")
        .allowsHitTesting(true) // 明确允许点击
    }
    
    // 提取处理点击的逻辑到单独函数
    private func handleTap() {
        print("二维码被点击: \(code.content)")
        print("二维码类型: \(code.type.rawValue)")
        
        // 触发视觉反馈
        withAnimation {
            isPressed = true
        }
        
        // 调用选择回调
        onSelect(code)
        
        // 短暂延迟后恢复未按下状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation {
                isPressed = false
            }
        }
    }
}

// 自定义按钮样式，处理按下状态
struct QRCodeButtonStyle: ButtonStyle {
    let isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed || isPressed ? 0.95 : 1.0)
            .brightness(configuration.isPressed || isPressed ? 0.1 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed || isPressed)
    }
}

#Preview {
    QRCodeOverlayView(codes: [
        QRCodeResult(content: "https://example.com", bounds: CGRect(x: 100, y: 100, width: 100, height: 100)),
        QRCodeResult(content: "https://apple.com", bounds: CGRect(x: 300, y: 100, width: 100, height: 100)),
    ]) { code in
        print("预览中选择了二维码: \(code.content)")
    }
} 
