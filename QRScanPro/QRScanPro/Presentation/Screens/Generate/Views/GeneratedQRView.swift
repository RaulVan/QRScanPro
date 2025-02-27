import SwiftUI
import CoreImage.CIFilterBuiltins
import Photos
import UIKit

struct GeneratedQRView: View {
    // MARK: - Properties
    let code: String
    let type: QRCodeType
    let onDismiss: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var historyManager: HistoryManager
    
    // State
    @State private var showShareSheet = false
    @State private var qrImage: UIImage? = nil
    @State private var saveStatus: SaveStatus = .none
//    @State private var fullQRImage: UIImage? = nil
    
    // MARK: - Model
    enum SaveStatus: Equatable {
        case none
        case saving
        case success
        case copied
        case failed(String)
        
        static func == (lhs: SaveStatus, rhs: SaveStatus) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none),
                 (.saving, .saving),
                 (.success, .success),
                 (.copied, .copied):
                return true
            case (.failed(let lhsMessage), .failed(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
        
        var icon: String? {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .failed: return "exclamationmark.circle.fill"
            case .copied: return "doc.on.doc"
            default: return nil
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .green
            case .failed: return .red   
            case .copied: return .blue
            default: return .secondary
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    qrCodeView
                    
                    Text(code)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    saveStatusView
                    
                    actionButtonsView
                }
                .padding(.vertical)
            }
            .navigationTitle("Generated QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                        onDismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = qrImage {
                    ShareSheet(items: [image])
                }
            }
            .onAppear(perform: generateQRCodeOnLoad)
        }
    }
    
    // MARK: - UI Components
    private var qrCodeView: some View {
        Group {
            if let qrImage = qrImage {
                VStack {
                     Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                        .frame(width: 280, height: 280)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(type.color.opacity(0.2), lineWidth: 2)
                        )
                        .shadow(
                            color: Color.gray.opacity(0.2),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                        .padding(.vertical)
                }
//                .id("QRCodeView")
//                .onChange(of: qrImage) { _ in
//                    createFullQRImage()
//                }
            } else {
                loadingView
                    .frame(width: 280, height: 280)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(type.color.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(
                        color: Color.gray.opacity(0.2),
                        radius: 10,
                        x: 0,
                        y: 5
                    )
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Generating QR code...")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .padding(30)
    }
    
    private var saveStatusView: some View {
        Group {
            switch saveStatus {
            case .saving:
                HStack {
                    ProgressView()
                    Text("Saving...")
                }
                .foregroundColor(.secondary)
                .transition(.opacity)
                
            case .success:
                statusMessageView(message: "Saved to Photos")
                    .onAppear { autoDismissStatus() }
                
            case .failed(let message):
                statusMessageView(message: message)
                    .onAppear { autoDismissStatus() }
                
            case .copied:
                statusMessageView(message: "Copied to Clipboard")
                    .onAppear { autoDismissStatus() }
                
            case .none:
                Color.clear.frame(height: 0)
            }
        }
        .padding(.vertical, 5)
        .animation(.easeInOut, value: saveStatus)
    }
    
    private func statusMessageView(message: String) -> some View {
        HStack {
            if let iconName = saveStatus.icon {
                Image(systemName: iconName)
            }
            Text(message)
        }
        .foregroundColor(saveStatus.color)
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 15) {
            actionButton(
                title: "Copy to Clipboard",
                icon: "doc.on.doc",
                action: copyToClipboard,
                style: .filled
            )
            
            actionButton(
                title: "Save to Photos",
                icon: "photo",
                action: saveToAlbum,
                style: .outlined,
                isDisabled: qrImage == nil || saveStatus == .saving
            )
            
            actionButton(
                title: "Share QR Code",
                icon: "square.and.arrow.up",
                action: shareQRCode,
                style: .outlined
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Views
    private enum ButtonStyle {
        case filled, outlined
    }
    
    private func actionButton(
        title: String,
        icon: String,
        action: @escaping () -> Void,
        style: ButtonStyle,
        isDisabled: Bool = false
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .foregroundColor(style == .filled ? .white : type.color)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    style == .filled
                    ? type.color
                    : type.color.opacity(0.1)
                )
                .overlay(
                    style == .outlined
                    ? RoundedRectangle(cornerRadius: 10).stroke(type.color, lineWidth: 1)
                    : nil
                )
                .cornerRadius(10)
        }
        .disabled(isDisabled)
    }
    
    // MARK: - Actions
    private func generateQRCodeOnLoad() {
        print("开始生成QR码, 内容: '\(code)'")
        
        // 在后台线程生成QR码
        DispatchQueue.global(qos: .userInitiated).async {
            guard !code.isEmpty else {
                print("QR码内容为空，无法生成")
                return
            }
            
            let image = generateQRCode(from: code)
            
            // 回到主线程更新UI
            DispatchQueue.main.async {
                self.qrImage = image
                print("QR码生成结果: \(image != nil ? "成功" : "失败")")
            }
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = code
        
        // Provide feedback
        let originalStatus = saveStatus
        saveStatus = .copied
        
        // Reset status after a brief moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.saveStatus == .copied {
                self.saveStatus = originalStatus
            }
        }
    }
    
    private func shareQRCode() {
        if qrImage != nil {
//            createFullQRImage()
            showShareSheet = true
        } else {
            showShareSheet = false
        }
        
    }
    
    private func autoDismissStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.saveStatus != .saving {
                self.saveStatus = .none
            }
        }
    }
    
    // MARK: - Photo Library Methods
    func saveToAlbum() {
        guard let image = qrImage else { return }
        saveStatus = .saving
        
        // Request permission first
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    self.createAlbumAndSaveImage(image: image)
                } else {
                    self.saveStatus = .failed("No permission to access Photos")
                }
            }
        }
    }
    
    func createAlbumAndSaveImage(image: UIImage) {
        let albumName = "QRScanPro"
        
        // Check if album already exists
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let assetCollection = collections.firstObject {
            saveImageToCollection(image: image, collection: assetCollection)
        } else {
            createAlbumAndSave(albumName: albumName, image: image)
        }
    }
    
    private func createAlbumAndSave(albumName: String, image: UIImage) {
        do {
            var albumPlaceholder: PHObjectPlaceholder?
            try PHPhotoLibrary.shared().performChangesAndWait {
                let createRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                albumPlaceholder = createRequest.placeholderForCreatedAssetCollection
            }
            
            if let placeholder = albumPlaceholder {
                let collections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                if let collection = collections.firstObject {
                    saveImageToCollection(image: image, collection: collection)
                    return
                }
            }
            
            // If we reach here, something went wrong
            DispatchQueue.main.async {
                saveStatus = .failed("Failed to create album")
            }
        } catch {
            DispatchQueue.main.async {
                saveStatus = .failed("Failed to create album: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveImageToCollection(image: UIImage, collection: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let placeholder = assetRequest.placeholderForCreatedAsset,
               let albumRequest = PHAssetCollectionChangeRequest(for: collection) {
                albumRequest.addAssets([placeholder] as NSArray)
            }
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    saveStatus = .success
                } else {
                    saveStatus = .failed("Save failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    // MARK: - QR Code Generation
    func generateQRCode(from string: String) -> UIImage? {
        // 再次检查字符串是否为空
        guard !string.isEmpty else { 
            print("QR码内容为空，无法生成")
            return nil 
        }
        
        print("正在生成QR码: \(string)")
        
        // 使用新的API方式
        let filter = CIFilter.qrCodeGenerator()
        let data = string.data(using: .utf8)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel") // 高纠错级别
        
        // 获取输出图像
        guard let outputImage = filter.outputImage else {
            print("无法从滤镜获取输出图像")
            return nil
        }
        
        // 缩放图像 (QR码原始图像非常小)
        let scale = 10.0
        let transformedImage = outputImage.transformed(
            by: CGAffineTransform(scaleX: scale, y: scale)
        )
        
        // 创建上下文并渲染
        let context = CIContext()
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            print("无法从变换后的图像创建CGImage")
            return nil
        }
        
        // 成功创建
        print("QR码图像创建成功")
        return UIImage(cgImage: cgImage)
    }
    
    private func createFullQRImage() {
        let qrCodeView = VStack {
            Image(uiImage: qrImage!)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .padding(20)
                .frame(width: 280, height: 280)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(type.color.opacity(0.2), lineWidth: 2)
                )
                .shadow(
                    color: Color.gray.opacity(0.2),
                    radius: 10,
                    x: 0,
                    y: 5
                )
        }
        .padding()
        .background(Color.white)
        
//        fullQRImage = qrCodeView.asUIImage()
//        showShareSheet = true
    }
} 


extension View {
    func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
