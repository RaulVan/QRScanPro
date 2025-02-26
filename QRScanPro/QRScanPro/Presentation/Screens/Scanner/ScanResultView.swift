import SwiftUI
import CoreImage.CIFilterBuiltins

struct ScanResultView: View {
    let code: String
    let onRescan: () -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var historyManager: HistoryManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // 扫描的二维码图片 距离顶部100
                if let qrImage = generateQRCode(from: code) {
                    Image(uiImage: qrImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.bottom)
                        .padding(.top, 50) // 添加顶部间距
                }
                
                // QR Code 内容
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Content")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(code)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .gray.opacity(0.2), radius: 5)
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                }
                
                // 操作按钮
                VStack(spacing: 12) {
                    Button(action: {
                        UIPasteboard.general.string = code
                    }) {
                        Label("Copy to Clipboard", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    if let url = URL(string: code), UIApplication.shared.canOpenURL(url) {
                        Button(action: {
                            UIApplication.shared.open(url)
                        }) {
                            Label("Open Link", systemImage: "safari")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button(action: {
                        dismiss()
                        onRescan()
                    }) {
                        Text("Scan Again")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal, 16) // 添加左右两边的间距
            }
            .navigationTitle("Scan Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            historyManager.addScannedRecord(code)
        }
    }

    // 生成二维码图片的函数
    func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return nil
    }
}

#Preview {
    ScanResultView(code: "https://explese.com", onRescan: {})
        .environmentObject(HistoryManager())
} 
