import SwiftUI

struct FocusAnimationView: View {
    let position: CGPoint
    @Binding var isVisible: Bool
    
    var body: some View {
        ZStack {
            // 外圈
            Circle()
                .stroke(Color.yellow, lineWidth: 1.5)
                .frame(width: 70, height: 70)
                .scaleEffect(isVisible ? 1.5 : 1.0)
                .opacity(isVisible ? 0 : 1)
            
            // 内圈
            Circle()
                .stroke(Color.yellow, lineWidth: 1.5)
                .frame(width: 40, height: 40)
                .scaleEffect(isVisible ? 0.5 : 1.0)
                .opacity(isVisible ? 0 : 1)
            
            // 中心点
            Circle()
                .fill(Color.yellow)
                .frame(width: 4, height: 4)
        }
        .position(x: position.x, y: position.y)
    }
} 