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
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(viewModel)
                .environmentObject(historyManager)
                .environmentObject(generateViewModel)
        }
    }
}
