import SwiftUI
import Foundation
import UIKit

struct RecordDetailView: View {
    let record: ScanRecord
    @Environment(\.dismiss) var dismiss
    
    @State private var qrImage: UIImage? = nil
    @State private var showShareSheet = false
    
    var body: some View {
        List {
            // QR Code Section
            Section {
                HStack {
                    Spacer()
                    if let qrImage = qrImage {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                            .frame(width: 180, height: 180)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(record.type.color.opacity(0.2), lineWidth: 2)
                            )
                            .shadow(
                                color: Color.gray.opacity(0.2),
                                radius: 10,
                                x: 0,
                                y: 5
                            )
                    } else {
                        ProgressView()
                            .frame(width: 180, height: 180)
                    }
                    Spacer()
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                .listRowBackground(Color.clear)
            }
            
            Section {
                
//                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: record.type.icon)
                            .font(.title)
                            .foregroundColor(record.type.color)
                        Text(record.type.rawValue.capitalized)
                            .font(.headline)
                    }
                    
                    Text(record.content)
                        .font(.body)
//                }
//                .padding(.vertical, 8)
//                .frame(maxWidth: .infinity)
            }
            
            
            // Time Section
            Section {
                HStack {
                    Text("Scanned on")
                    Spacer()
                    Text(record.timestamp, style: .date)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Time")
                    Spacer()
                    Text(record.timestamp, style: .time)
                        .foregroundColor(.secondary)
                }
            }
            
            // Actions Section
            Section {
                Button(action: {
                    UIPasteboard.general.string = record.content
                }) {
                    Label("Copy to Clipboard", systemImage: "doc.on.doc")
                }
                
                if let url = URL(string: record.content), UIApplication.shared.canOpenURL(url) {
                    Button(action: {
                        UIApplication.shared.open(url)
                    }) {
                        Label("Open Link", systemImage: "safari")
                    }
                }
                
                Button(action: {
                    showShareSheet = true
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = qrImage {
                ShareSheet(items: [image, record.content])
            }
        }
        .onAppear {
            generateQRCode()
        }
    }
    
    // 生成二维码
    private func generateQRCode() {
        guard !record.content.isEmpty else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let filter = CIFilter.qrCodeGenerator()
            let data = record.content.data(using: .utf8)
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            
            if let outputImage = filter.outputImage {
                let scale = 10.0
                let transformedImage = outputImage.transformed(
                    by: CGAffineTransform(scaleX: scale, y: scale)
                )
                
                let context = CIContext()
                if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                    DispatchQueue.main.async {
                        self.qrImage = UIImage(cgImage: cgImage)
                    }
                }
            }
        }
    }
}
