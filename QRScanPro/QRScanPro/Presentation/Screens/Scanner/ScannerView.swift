import SwiftUI
import AVFoundation
import UIKit

struct ScannerView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @EnvironmentObject var historyManager: HistoryManager
    @StateObject private var scanner = QRCodeScanner()
    @State private var showImagePicker = false
    @State private var showSubscription = false
    @State private var showPermissionDenied = false
    @State private var showPhotoLibraryPermissionDenied = false
    @State private var isScanning = true
    @State private var showResult = false
    @State private var selectedImage: UIImage?
    @State private var selectedCode: QRCodeResult?
    @State private var permissionDeniedType: PermissionType = .camera
    @State private var animationOffset: CGFloat = 0
    // @State private var scannedCode: String?
    
    
    
    var body: some View {
        ZStack {
            // Camera preview
            if let previewLayer = scanner.getPreviewLayer() {
                ZStack {
                    // 1. 底层是相机预览
                    CameraPreviewView(previewLayer: previewLayer)
                        .edgesIgnoringSafeArea(.all)
                    
                    // UI元素 (工具栏、扫描框等)
                    VStack {
                        // Top toolbar
                        HStack {
                            Button(action: handleImagePickerTap) {
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                                    .padding(10)
                                    .background(Circle().fill(Color.black.opacity(0.5)))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                print("闪光灯切换: \(!scanner.isFlashOn)")
                                scanner.toggleFlash()
                            }) {
                                Image(systemName: scanner.isFlashOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                                    .padding(10)
                                    .background(Circle().fill(Color.black.opacity(0.5)))
                            }
                        }
                        .padding()
                        
                        Spacer()
                        
                        // Scan frame
                        ZStack {
                            // Scan frame corners
                            ScannerCorners(width: 280, height: 280, color: .white, cornerLength: 30, lineWidth: 5)
                            
                            // Scanning line animation
                            if isScanning {
                                VStack(spacing: 0) {
                                    // Gradient scan line
                                    Rectangle()
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [.green.opacity(0.0), .green.opacity(0.7), .green.opacity(0.0)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                        .frame(width: 270, height: 3)
                                        .blur(radius: 0.5)
                                    
                                    // 扫描区域 - 完全透明，不影响二维码可见性
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: 270, height: 270)
                                }
                                .offset(y: animationOffset)
                                .animation(
                                    .easeInOut(duration: 2)
                                    .repeatForever(autoreverses: true),
                                    value: animationOffset
                                )
                                .clipShape(Rectangle().size(width: 270, height: 280))
                                
                            }
                            
                            // 当扫描到二维码时，添加一个柔和的高亮效果
                            if !scanner.scannedCodes.isEmpty && !isScanning {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.green, lineWidth: 2)
                                    .frame(width: 270, height: 270)
                                    .opacity(0.6)
                                
                            }
                        }
                        .frame(width: 280, height: 280)
                        
                        // Text hint below scan frame
                        Text(scanner.scannedCodes.isEmpty ? "Scan QR Code" : "Tap QR code to view")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 16)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(8)
                            .padding(.top, 30)
                        
                        
                        Spacer()
                        
                        // Empty bottom area for spacing
                        HStack {
                            Spacer()
                        }
                        .padding(.bottom, 40)
                    }
                    
                    //                    QRCodeOverlayView(codes: [
                    //                        QRCodeResult(content: "https://example.com", bounds: CGRect(x: 100, y: 100, width: 100, height: 100)),
                    ////                        QRCodeResult(content: "https://apple.com", bounds: CGRect(x: 300, y: 100, width: 100, height: 100)),
                    //                    ]) { code in
                    //                        print("预览中选择了二维码: \(code.content)")
                    //                    }.zIndex(99) // 确保在最上层
                    //                        .id("qrCodeOverlay-\(scanner.scannedCodes.count)") // 添加id以避免不必要的重绘
                    //                        .allowsHitTesting(true) // 明确允许点击
                    //                        .onAppear {
                    //                            print("ScannerView - 二维码覆盖层出现，数量: \(scanner.scannedCodes.count)")
                    //                        }
                    
                    // 3. 最顶层是二维码覆盖层，确保它在最上面可以接收点击
                    if !scanner.scannedCodes.isEmpty {
                        // 使用合并后的二维码覆盖视图
                        //                        let codes = [QRCodeResult(content: "https://example.com", bounds: CGRect(x: 100, y: 100, width: 100, height: 100)),
                        //                                     QRCodeResult(content: "https://apple.com", bounds: CGRect(x: 300, y: 100, width: 100, height: 100))]
                        QRCodeOverlayView(codes: scanner.scannedCodes) { code in
                            print("ScannerView - 选择二维码: \(code.content)")
                            print("ScannerView - 选择处理开始 - 二维码详情:")
                            print("ScannerView - 内容: \(code.content)")
                            print("ScannerView - 类型: \(code.type.rawValue)")
                            print("ScannerView - 位置: \(code.bounds)")
                            
                            // 添加触觉反馈，立即响应用户操作
                            hapticFeedback()
                            
                            selectedCode = code
                            print("ScannerView - 已设置选中的二维码，准备显示结果")
                            
                            // 延迟一下再弹出结果页面，确保视觉反馈完成
                            //                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showResult = true
                            print("ScannerView - 结果页面即将显示: showResult = true")
                            //                            }
                        }
                        .zIndex(100) // 确保在最上层
                        .id("qrCodeOverlay-\(scanner.scannedCodes.count)") // 添加id以避免不必要的重绘
                        .allowsHitTesting(true) // 明确允许点击
                        .onAppear {
                            print("ScannerView - 二维码覆盖层出现，数量: \(scanner.scannedCodes.count)")
                        }
                    }
                    
                    // 添加 ProBannerView 到最顶层
                    if !viewModel.isSubscribed {
                        VStack {
                            ProBannerView(showSubscription: $showSubscription)
                                .padding(.horizontal)
                                .padding(.top, 60) // 调整顶部边距，避免与状态栏重叠
                                .onTapGesture {
                                    print("订阅横幅被点击")
                                    showSubscription = true
                                }
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(150) // 设置比二维码覆盖层更高的层级
                        .allowsHitTesting(true) // 确保横幅可以接收点击事件
                    }
                }
//#if compiler(>=5.9)
//                .onChange(of: scanner.scannedCodes) { oldCodes, newCodes in
//                    handleScannedCodesChange(newCodes)
//                }
//#else
                .onChange(of: scanner.scannedCodes) { codes in
                    handleScannedCodesChange(codes)
                }
//#endif
            } else {
                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            print("扫描页面出现")
            checkCameraPermission()
        }
        .onDisappear {
            print("扫描页面消失")
            scanner.stop()
            isScanning = false
            //            autoOpenTimer?.invalidate()
            //            autoOpenTimer = nil
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView(showCloseButton: true)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, onScan: handleImageScan)
        }
        .sheet(isPresented: $showResult) {
            //            print("结果页面已显示，显示二维码内容: \(selectedCode?.content ?? "无内容")")
            if let code = selectedCode {
                ScanResultView(
                    code: code.content,
                    onRescan: {
                        showResult = false
                        resetScanning()
                    }
                )
            }
        }
        .alert(permissionDeniedType.title, isPresented: $showPermissionDenied) {
            Button("Open Settings", action: openSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(permissionDeniedType.message)
        }
        .onChange(of: selectedCode) { newCode in
            if let code = newCode {
                selectedCode = code
                // 添加到历史记录
                historyManager.addScannedRecord(code.content)
                showResult = true
            }
        }
    }
    
    private func checkCameraPermission() {
        print("检查相机权限")
        CameraPermissionManager.requestCameraPermission { granted in
            if granted {
                print("相机权限已授予")
                DispatchQueue.main.async {
                    self.scanner.start()
                    withAnimation {
                        self.isScanning = true
                        self.animationOffset = 270  // 设置动画终点为底部
                    }
                }
            } else {
                print("相机权限被拒绝")
                permissionDeniedType = .camera
                showPermissionDenied = true
            }
        }
    }
    
    private func handleImageScan(_ image: UIImage) {
        print("处理图片中的二维码")
        QRCodeDetector.detectQRCode(in: image) { code in
            if let code = code {
                print("图片中检测到二维码: \(code)")
                selectedCode = QRCodeResult(content: code, bounds: .zero)
                showResult = true
            } else {
                print("图片中未检测到二维码")
            }
        }
    }
    
    private func handleImagePickerTap() {
        print("点击相册按钮")
        CameraPermissionManager.requestPhotoLibraryPermission { granted in
            if granted {
                print("相册权限已授予")
                showImagePicker = true
            } else {
                print("相册权限被拒绝")
                permissionDeniedType = .photoLibrary
                showPermissionDenied = true
            }
        }
    }
    
    private func openSettings() {
        print("打开设置")
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func handleScannedCodesChange(_ codes: [QRCodeResult]) {
        // 使用 DispatchQueue 延迟更新UI，避免频繁刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if !codes.isEmpty {
                if isScanning {
                    print("扫描到二维码，停止扫描动画")
                    withAnimation {
                        isScanning = false
                    }
                    hapticFeedback()
                }
            } else if codes.isEmpty && !isScanning {
                print("未检测到二维码，恢复扫描")
                withAnimation {
                    isScanning = true
                    animationOffset = 0
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            self.animationOffset = 270
                        }
                    }
                }
            }
        }
    }
    
    // 提供触觉反馈
    private func hapticFeedback() {
        print("触发触觉反馈")
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    private func resetScanning() {
        print("重置扫描")
        // 清除选中的二维码
        selectedCode = nil
        
        // 重新启动扫描 - 不需要重新启动相机，只需要清空已扫描的码
        scanner.clearScannedCodes()
        print("已清空扫描的二维码列表")
        
        // 重新启动动画
        withAnimation {
            isScanning = true
            animationOffset = 0  // 从顶部开始
            
            // 延迟设置终点，确保动画能流畅开始
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    self.animationOffset = 270  // 移动到底部
                }
            }
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let onScan: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                print("已从相册选择图片")
                parent.image = image
                parent.onScan(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("取消图片选择")
            parent.dismiss()
        }
    }
}

#Preview {
    ScannerView()
        .environmentObject(AppViewModel())
}

struct ToolbarButton: View {
    let icon: String
    let text: String
    var isMain: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                if isMain {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 60, height: 60)
                }
                Image(systemName: icon)
                    .font(.system(size: isMain ? 30 : 24))
                    .foregroundColor(isMain ? .black : .white)
            }
            Text(text)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

// Scanner corner view
struct ScannerCorners: View {
    let width: CGFloat
    let height: CGFloat
    let color: Color
    let cornerLength: CGFloat
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            // Left top corner
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(color)
                        .frame(width: cornerLength, height: lineWidth)
                    Spacer()
                }
                
                Rectangle()
                    .fill(color)
                    .frame(width: lineWidth, height: cornerLength)
                
                Spacer()
            }
            .frame(width: width/2, height: height/2)
            .position(x: width/4, y: height/4)
            
            // Right top corner
            VStack(alignment: .trailing, spacing: 0) {
                HStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(color)
                        .frame(width: cornerLength, height: lineWidth)
                }
                
                Rectangle()
                    .fill(color)
                    .frame(width: lineWidth, height: cornerLength)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                Spacer()
            }
            .frame(width: width/2, height: height/2)
            .position(x: width * 3/4, y: height/4)
            
            // Left bottom corner
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                Rectangle()
                    .fill(color)
                    .frame(width: lineWidth, height: cornerLength)
                
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(color)
                        .frame(width: cornerLength, height: lineWidth)
                    Spacer()
                }
            }
            .frame(width: width/2, height: height/2)
            .position(x: width/4, y: height * 3/4)
            
            // Right bottom corner
            VStack(alignment: .trailing, spacing: 0) {
                Spacer()
                
                Rectangle()
                    .fill(color)
                    .frame(width: lineWidth, height: cornerLength)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                HStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(color)
                        .frame(width: cornerLength, height: lineWidth)
                }
            }
            .frame(width: width/2, height: height/2)
            .position(x: width * 3/4, y: height * 3/4)
        }
        .frame(width: width, height: height)
    }
}
