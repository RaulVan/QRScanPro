//
//  QRScanProApp.swift
//  QRScanPro
//
//  Created by Guck on 2025/2/19.
//

import SwiftUI

@main
struct QRScanProApp: App {
    // 创建单个实例的 StateObject
    @StateObject private var viewModel = AppViewModel()
    @StateObject private var historyManager = HistoryManager()
    @StateObject private var generateViewModel = GenerateViewModel()
    
    // 添加状态来控制是否显示启动屏幕
    @State private var showLaunchScreen = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
               
                // 启动屏幕
                if showLaunchScreen {
                    LaunchScreenView()
                        .environmentObject(viewModel)
                        .environmentObject(historyManager)
                        .environmentObject(generateViewModel)
                        .transition(.opacity)
                        .zIndex(1)  // 确保启动屏幕在最上层
                }
            }
            .onAppear {
                // 延迟 2 秒后隐藏启动屏幕
                // DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                //     withAnimation {
                //         showLaunchScreen = false
                //     }
                // }
            }
        }
    }
}
