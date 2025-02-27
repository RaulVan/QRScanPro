import SwiftUI
import CoreImage.CIFilterBuiltins
import Photos

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
    
    // MARK: - Model
    enum SaveStatus: Equatable {
        case none
        case saving
        case success
        case failed(String)
        
        static func == (lhs: SaveStatus, rhs: SaveStatus) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none),
                 (.saving, .saving),
                 (.success, .success):
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
            default: return nil
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .green
            case .failed: return .red
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
                Image(uiImage: qrImage)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.3), radius: 10)
                    )
            } else {
                loadingView
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Generating QR code...")
                .foregroundColor(.secondary)
                .padding()
        }
        .frame(width: 250, height: 250)
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
        if qrImage == nil {
            DispatchQueue.global(qos: .userInitiated).async {
                let generatedImage = generateQRCode(from: code)
                DispatchQueue.main.async {
                    qrImage = generatedImage
                    print("QR code generation: \(qrImage != nil ? "success" : "failed")")
                }
            }
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = code
        
        // Provide feedback
        let originalStatus = saveStatus
        saveStatus = .success
        
        // Reset status after a brief moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.saveStatus == .success {
                self.saveStatus = originalStatus
            }
        }
    }
    
    private func shareQRCode() {
        // Double check image exists
        if qrImage == nil {
            qrImage = generateQRCode(from: code)
        }
        showShareSheet = true
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
        guard !string.isEmpty else { 
            print("Cannot generate QR code from empty string")
            return nil 
        }
        
        print("Generating QR code for: \(string)")
        
        // 使用 CIFilter.qrCodeGenerator() 而不是通过名称创建
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        
        // 获取输出图像
        guard let outputImage = filter.outputImage else {
            print("Failed to get output image from filter")
            return nil
        }
        
        // 缩放图像 (QR 码原始图像非常小)
        let scale = 10.0
        let transformedImage = outputImage.transformed(
            by: CGAffineTransform(scaleX: scale, y: scale)
        )
        
        // 创建上下文并渲染
        let context = CIContext()
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            print("Failed to create CGImage from transformed image")
            return nil
        }
        
        // 成功创建
        print("QR code image created successfully")
        return UIImage(cgImage: cgImage)
    }
} 