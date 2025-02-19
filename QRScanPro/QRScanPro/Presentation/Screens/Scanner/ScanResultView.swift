import SwiftUI

struct ScanResultView: View {
    let code: String
    let onRescan: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // QR Code 内容
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Scanned Content")
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
    }
}

#Preview {
    ScanResultView(code: "https://www.example.com", onRescan: {})
} 