import SwiftUI

struct ProBannerView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var showSubscription: Bool
    
    var body: some View {
        Button(action: {
            showSubscription = true
        }) {
            HStack(spacing: 12) {
                // 左侧图标和文字
                HStack {
                    // Image(systemName: "person.crop.circle.fill")
                    //     .font(.title2)
                    //     .foregroundColor(.green)
                    headerSection
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Go Pro")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            FeatureText(text: "Batch Scan & Pin")
                            FeatureText(text: "Protect Custom QR Codes")
                            FeatureText(text: "NO Ads")
                        }
                    }
                }
                
                Spacer()
                
               
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                Text("PRO")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red)
                    )
                    .padding(8),
                alignment: .topTrailing
            )
        }
    }
}

struct FeatureText: View {
    let text: String
    
    var body: some View {
        Text("✅" + text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

 private var headerSection: some View {
        VStack(spacing: 0) {
            // Illustration
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
            }
        }
    }

#Preview {
    ProBannerView(showSubscription: .constant(false))
        .environmentObject(AppViewModel())
        .padding()
        .background(Color.gray.opacity(0.1))
} 
