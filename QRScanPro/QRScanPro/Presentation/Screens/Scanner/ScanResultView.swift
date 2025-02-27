import SwiftUI
import CoreImage.CIFilterBuiltins

struct ScanResultView: View {
    let code: String
    let onRescan: () -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var historyManager: HistoryManager
    
    @State private var resultLoaded = false
    @State private var toastMessage: String?
    @State private var showShareSheet = false
    @State private var qrImage: UIImage?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // QR码类型图标
                    let codeType = QRCodeType.detect(from: code)
                    
                    ZStack {
                        Circle()
                            .fill(codeType.color.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: codeType.icon)
                            .font(.system(size: 36))
                            .foregroundColor(codeType.color)
                    }
                    .padding(.top, 20)
                    
                    // 类型标题
                    Text(codeType.title)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // 内容卡片
                    VStack(alignment: .leading) {
                        Text("Content")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                        
                        Text(code)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                UIPasteboard.general.string = code
                                showToast("Copied to clipboard")
                            }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .gray.opacity(0.2), radius: 5)
                    )
                    .padding(.horizontal)
                    
                    // QR码图像
                    if let qrImage = qrImage {
                        Image(uiImage: qrImage)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: .gray.opacity(0.2), radius: 5)
                            )
                    }
                    
                    // 操作按钮
                    VStack(spacing: 12) {
                        Button(action: {
                            UIPasteboard.general.string = code
                            showToast("Copied to clipboard")
                        }) {
                            Label("Copy to Clipboard", systemImage: "doc.on.doc")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(codeType.color.opacity(0.1))
                                .foregroundColor(codeType.color)
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                        
                        if let url = URL(string: code), UIApplication.shared.canOpenURL(url) {
                            Button(action: {
                                UIApplication.shared.open(url)
                            }) {
                                Label("Open Link", systemImage: "safari")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(codeType.color.opacity(0.1))
                                    .foregroundColor(codeType.color)
                                    .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Button(action: {
                            showShareSheet = true
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(codeType.color.opacity(0.1))
                                .foregroundColor(codeType.color)
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                        .disabled(qrImage == nil)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
                .overlay(
                    // Toast消息
                    ToastView(message: toastMessage)
                        .animation(.easeInOut(duration: 0.2), value: toastMessage != nil)
                        .transition(.move(edge: .top).combined(with: .opacity))
                )
            }
            .navigationTitle("Scan Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                        onRescan()
                    }) {
                        Text("Rescan")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // 在视图出现时生成QR码图像
                DispatchQueue.global(qos: .userInitiated).async {
                    let image = generateQRCode(from: code)
                    DispatchQueue.main.async {
                        self.qrImage = image
                        self.resultLoaded = true
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let qrImage = qrImage {
                    ShareSheet(items: [qrImage, code])
                }
            }
        }
    }
    
    // 生成二维码图片的函数
    func generateQRCode(from string: String) -> UIImage? {
        guard !string.isEmpty else { return nil }
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            let scale = 10.0
            let transformedImage = outputImage.transformed(
                by: CGAffineTransform(scaleX: scale, y: scale)
            )
            
            if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
    
    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            toastMessage = nil
        }
    }
}

struct ToastView: View {
    let message: String?
    
    var body: some View {
        if let message = message {
            VStack {
                Text(message)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.8))
                    )
                    .foregroundColor(.white)
                    .font(.subheadline)
                
                Spacer()
            }
            .padding(.top, 16)
        } else {
            EmptyView()
        }
    }
}


#Preview {
    ScanResultView(code: "https://explese.com", onRescan: {})
        .environmentObject(HistoryManager())
} 
