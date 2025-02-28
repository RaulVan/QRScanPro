import SwiftUI

struct LaunchScreenView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @Environment(\.colorScheme) var colorScheme
    
    // 自定义颜色
    private var gradientColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.4, green: 0.2, blue: 0.6), // 深紫色
                Color(red: 0.1, green: 0.1, blue: 0.2)  // 深蓝黑色
            ]
        } else {
            return [
                Color(red: 0.6, green: 0.4, blue: 0.9), // 浅紫色
                Color(red: 0.4, green: 0.2, blue: 0.8)  // 中紫色
            ]
        }
    }
    
    var body: some View {
        if isActive {
            if viewModel.isSubscribed {
                MainTabView()
            } else {
                SubscriptionView(showCloseButton: true)
            }
        } else {
            ZStack {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 背景装饰元素
                ZStack {
                    // 左上角装饰
                    Circle()
                        .fill(
                            colorScheme == .dark
                                ? Color.white.opacity(0.08)
                                : Color.white.opacity(0.15)
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 30)
                        .offset(x: -100, y: -120)
                    
                    // 右上角装饰
                    Circle()
                        .fill(
                            colorScheme == .dark
                                ? Color.purple.opacity(0.15)
                                : Color.white.opacity(0.2)
                        )
                        .frame(width: 180, height: 180)
                        .blur(radius: 25)
                        .offset(x: 120, y: -150)
                    
                    // 右下角装饰
                    Circle()
                        .fill(
                            colorScheme == .dark
                                ? Color.purple.opacity(0.15)
                                : Color.white.opacity(0.2)
                        )
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                        .offset(x: 100, y: 200)
                    
                    // 左下角装饰
                    Circle()
                        .fill(
                            colorScheme == .dark
                                ? Color.white.opacity(0.08)
                                : Color.white.opacity(0.15)
                        )
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)
                        .offset(x: -120, y: 180)
                }
                
                // 主要内容
                VStack(spacing: 25) {
                    // Logo 容器
                    ZStack {
                        // Logo 背景光晕
                        Circle()
                            .fill(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.05)
                                    : Color.white.opacity(0.3)
                            )
                            .frame(width: 150, height: 150)
                            .blur(radius: 10)
                        
                        Circle()
                            .fill(
                                colorScheme == .dark
                                    ? Color.black.opacity(0.5)
                                    : Color.white.opacity(0.4)
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundStyle(
                                colorScheme == .dark
                                    ? Color.white
                                    : Color.white
                            )
                    }
                    .shadow(
                        color: colorScheme == .dark
                            ? Color.purple.opacity(0.3)
                            : Color.purple.opacity(0.4),
                        radius: 15,
                        x: 0,
                        y: 5
                    )
                    
                    VStack(spacing: 12) {
                        Text("QR Scan Pro")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Text("Scan · Generate · Share")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.8)
                                    : Color.white
                            )
                    }
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
        .environmentObject(AppViewModel())
} 