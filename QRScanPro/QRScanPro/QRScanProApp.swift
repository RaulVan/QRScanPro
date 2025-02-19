//
//  QRScanProApp.swift
//  QRScanPro
//
//  Created by Guck on 2025/2/19.
//

import SwiftUI

@main
struct QRScanProApp: App {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .environmentObject(viewModel)
        }
    }
}
