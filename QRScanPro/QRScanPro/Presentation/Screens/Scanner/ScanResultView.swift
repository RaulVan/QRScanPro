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
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .gray.opacity(0.2), radius: 5)
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // 使 VStack 填充可用宽度
                    .padding()
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
                .padding()
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
    ScanResultView(code: "@ScanResultView.swift  优化扫描结果UI：1. 添加扫描的二维码图 2. 扫描内容布局调整更合理些。We're experiencing high demand for Claude 3.7 Sonnet right now. Please try again in a few minutes.", onRescan: {})
        .environmentObject(HistoryManager())
} 
