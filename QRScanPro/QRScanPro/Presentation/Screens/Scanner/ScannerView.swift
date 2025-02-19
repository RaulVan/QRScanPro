import SwiftUI
import AVFoundation
import UIKit

struct ScannerView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @StateObject private var scanner = QRCodeScanner()
    @State private var showImagePicker = false
    @State private var showSubscription = false
    @State private var showPermissionDenied = false
    @State private var showPhotoLibraryPermissionDenied = false
    @State private var isScanning = false
    @State private var showResult = false
    @State private var selectedImage: UIImage?
    @State private var focusPoint: CGPoint = .zero
    @State private var showFocusAnimation = false
    @State private var selectedCode: QRCodeResult?
    @State private var permissionDeniedType: PermissionType = .camera
    
    enum PermissionType {
        case camera
        case photoLibrary
        
        var title: String {
            switch self {
            case .camera:
                return "Camera Access Denied"
            case .photoLibrary:
                return "Photo Library Access Denied"
            }
        }
        
        var message: String {
            switch self {
            case .camera:
                return "Please allow camera access in Settings to scan QR codes."
            case .photoLibrary:
                return "Please allow photo library access in Settings to select photos."
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Camera preview
            if let previewLayer = scanner.getPreviewLayer() {
                CameraPreviewView(previewLayer: previewLayer)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture { location in
                                handleFocus(at: location)
                            }
                    )
                    .overlay(
                        FocusAnimationView(position: focusPoint, isVisible: $showFocusAnimation)
                            .opacity(showFocusAnimation ? 1 : 0)
                    )
                    .overlay(
                        QRCodeOverlayView(codes: scanner.scannedCodes) { code in
                            selectedCode = code
                            showResult = true
                        }
                    )
            } else {
                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                // Top toolbar
                HStack {
                    Button(action: handleImagePickerTap) {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                    
                    Spacer()
                    
                    Button(action: { scanner.toggleFlash() }) {
                        Image(systemName: scanner.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                }
                .padding()
                
                if !viewModel.isSubscribed {
                    ProBannerView(showSubscription: $showSubscription)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Scan frame
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 250, height: 250)
                    
                    // Scanning line animation
                    if isScanning {
                        Rectangle()
                            .fill(Color.green.opacity(0.5))
                            .frame(height: 2)
                            .offset(y: -60)
                            .animation(
                                Animation.easeInOut(duration: 2)
                                    .repeatForever(autoreverses: true),
                                value: isScanning
                            )
                    }
                }
                
                Text(scanner.scannedCodes.isEmpty ? "Align the QR code within\nthe frame to scan" : "Tap on a QR code to select")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                Spacer()
            }
        }
        .onAppear {
            checkCameraPermission()
        }
        .onDisappear {
            scanner.stop()
            isScanning = false
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView(showCloseButton: true)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, onScan: handleImageScan)
        }
        .sheet(isPresented: $showResult) {
            if let code = selectedCode {
                ScanResultView(code: code.content) {
                    selectedCode = nil
                    scanner.start()
                    withAnimation {
                        isScanning = true
                    }
                }
            }
        }
        .alert(permissionDeniedType.title, isPresented: $showPermissionDenied) {
            Button("Open Settings", action: openSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(permissionDeniedType.message)
        }
    }
    
    private func handleFocus(at location: CGPoint) {
        guard let previewLayer = scanner.getPreviewLayer() else { return }
        
        // 将点击位置转换为相机坐标系统
        let focusPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: location)
        scanner.focus(at: focusPoint)
        
        // 显示对焦动画
        self.focusPoint = location
        withAnimation(.easeInOut(duration: 0.3)) {
            showFocusAnimation = true
        }
        
        // 动画结束后隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showFocusAnimation = false
            }
        }
    }
    
    private func checkCameraPermission() {
        CameraPermissionManager.requestCameraPermission { granted in
            if granted {
                DispatchQueue.main.async {
                    self.scanner.start()
                    withAnimation {
                        self.isScanning = true
                    }
                }
            } else {
                permissionDeniedType = .camera
                showPermissionDenied = true
            }
        }
    }
    
    private func handleImageScan(_ image: UIImage) {
        QRCodeDetector.detectQRCode(in: image) { code in
            if let code = code {
                selectedCode = QRCodeResult(content: code, bounds: .zero)
                showResult = true
            }
        }
    }
    
    private func handleImagePickerTap() {
        CameraPermissionManager.requestPhotoLibraryPermission { granted in
            if granted {
                showImagePicker = true
            } else {
                permissionDeniedType = .photoLibrary
                showPermissionDenied = true
            }
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
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
                parent.image = image
                parent.onScan(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
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
